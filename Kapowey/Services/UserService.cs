using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using API = Kapowey.Models.API.Entities;
using Mapster;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NodaTime;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Kapowey.Caching;
using System.Linq;
using System.Collections.Generic;
using System.Security.Claims;

namespace Kapowey.Services
{
    public class UserService : ServiceBase, IUserService
    {
        private IJwtService JwtService { get; }
        private IPasswordHasher<User> PasswordHasher { get; }
        public ILogger<UserService> Logger { get; set; }

        public UserService(
            IOptions<AppSettings> appSettings,
            ILogger<UserService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IJwtService jwtService,
            IPasswordHasher<User> passwordHasher)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            JwtService = jwtService;
            PasswordHasher = passwordHasher;
        }

        public async Task<IPagedResponse<API.UserInfo>> ListAsync(User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.UserInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<User, API.UserInfo >(DbContext.User, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteUserAsync(User user, Guid apiKey)
        {
            var userToDelete = await DbContext.Users.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if(userToDelete == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.User.Remove(userToDelete);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: User `{ userToDelete }`.");
            return new ServiceResponse<bool>(true);
        }


        public async Task<IServiceResponse<AuthenticateResponse>> AuthenticateAsync(AuthenticateRequest request)
        {
            var user = await DbContext.User
                                      .Include(x => x.Claims)
                                      .Include(x => x.UserUserRole).ThenInclude(x => x.UserRole).ThenInclude(x => x.Claims)
                                      .FirstOrDefaultAsync(x => x.UserName == request.Username).ConfigureAwait(false);
            if (user == null)
            {
                return new ServiceResponse<AuthenticateResponse>(new ServiceResponseMessage("Invalid User", ServiceResponseMessageType.Authentication));
            }
            switch (PasswordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password))
            {
                case PasswordVerificationResult.Success:
                    var apiUser = user.Adapt<API.UserInfo >();
                    apiUser.Roles = user.UserRoles?.Select(x => x.Role.Name);
                    var claims = new List<Claim>();
                    claims.AddRange(user.Claims?.Select(x => new Claim(x.ClaimType, x.ClaimValue)) ?? Enumerable.Empty<Claim>());
                    claims.AddRange(user.UserRoles?.Select(x => x.UserRole)?
                                                   .SelectMany(x => x.Claims)?
                                                   .Where(x => x != null)
                                                   .Select(x => new Claim(x.ClaimType, x.ClaimValue)) ?? Enumerable.Empty<Claim>());
                    apiUser.Claims = claims;
                    var model = new AuthenticateResponse(apiUser, JwtService.GenerateSecurityToken(apiUser));
                    user.LastAuthenticateDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
                    user.SuccessfulAuthenticateCount = user.SuccessfulAuthenticateCount.HasValue ? user.SuccessfulAuthenticateCount + 1 : 1;
                    await DbContext.SaveChangesAsync().ConfigureAwait(false);
                    return new ServiceResponse<AuthenticateResponse>(model, new ServiceResponseMessage(ServiceResponseMessageType.Ok));

                case PasswordVerificationResult.SuccessRehashNeeded:
                    throw new NotImplementedException();
            }
            return new ServiceResponse<AuthenticateResponse>(new ServiceResponseMessage("Invalid Authorization Attempt", ServiceResponseMessageType.Authentication));
        }

        public async Task<IServiceResponse<int>> Register(API.UserInfo model)
        {
            try
            {
                var newUser = new User
                {
                    UserName = model.UserName,
                    NormalizedUserName = model.UserName.ToUpper(),
                    Email = model.Email,
                    NormalizedEmail = model.Email.ToUpper()
                };
                newUser.PasswordHash = PasswordHasher.HashPassword(newUser, model.Password);
                await DbContext.User.AddAsync(newUser).ConfigureAwait(false);
                await DbContext.SaveChangesAsync().ConfigureAwait(false);
                if(newUser.Id == 1) // First user to register
                {
                    var adminRole = await DbContext.UserRole.FirstOrDefaultAsync(x => x.Name == "Admin").ConfigureAwait(false);
                    if (adminRole == null)
                    {
                        // Create User Roles
                        await DbContext.UserRole.AddAsync(new UserRole
                        {
                            Name = "Admin",
                            NormalizedName = "ADMIN",
                            ConcurrencyStamp = Guid.NewGuid().ToString()
                        }).ConfigureAwait(false);
                        await DbContext.UserRole.AddAsync(new UserRole
                        {
                            Name = "Manager",
                            NormalizedName = "MANAGER",
                            ConcurrencyStamp = Guid.NewGuid().ToString()
                        }).ConfigureAwait(false);
                        await DbContext.UserRole.AddAsync(new UserRole
                        {
                            Name = "Editor",
                            NormalizedName = "EDITOR",
                            ConcurrencyStamp = Guid.NewGuid().ToString()
                        }).ConfigureAwait(false);
                        await DbContext.UserRole.AddAsync(new UserRole
                        {
                            Name = "Contributor",
                            NormalizedName = "CONTRIBUTOR",
                            ConcurrencyStamp = Guid.NewGuid().ToString()
                        }).ConfigureAwait(false);
                        await DbContext.SaveChangesAsync().ConfigureAwait(false);
                        adminRole = await DbContext.UserRole.FirstOrDefaultAsync(x => x.Name == "Admin").ConfigureAwait(false);
                    }
                    if(adminRole == null)
                    {
                        throw new Exception("Unable to add initial user to Admin role");
                    }
                    // Add user as Admin
                    await DbContext.UserUserRole.AddAsync(new UserUserRole
                    {
                        UserId = newUser.Id,
                        RoleId = adminRole.UserRoleId
                    }).ConfigureAwait(false);
                    await DbContext.SaveChangesAsync().ConfigureAwait(false);
                    CacheManager.Clear();
                }
                return new ServiceResponse<int>(newUser.Id, new ServiceResponseMessage(ServiceResponseMessageType.Ok));
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Register", model);
            }
            return new ServiceResponse<int>(new ServiceResponseMessage("An Error has occured", ServiceResponseMessageType.Error));
        }

        public static bool IsNewPasswordStrongEnough(string password)
        {
            switch (CheckPasswordStrength(password))
            {
                case PasswordScore.Medium:
                case PasswordScore.Strong:
                case PasswordScore.VeryStrong:
                    return true;
            }
            return false;
        }

        public static PasswordScore CheckPasswordStrength(string password)
        {
            int score = 0;

            if ((password?.Length ?? 0) < 1)
            {
                return PasswordScore.Blank;
            }
            if (password.Length < 4)
            {
                return PasswordScore.VeryWeak;
            }
            if (password.Length >= 8)
            {
                score++;
            }
            if (password.Length >= 12)
            {
                score++;
            }
            if (Regex.Match(password, @"\d+", RegexOptions.IgnoreCase).Success)
            {
                score++;
            }
            if (Regex.Match(password, "[a-z]", RegexOptions.IgnoreCase).Success &&
              Regex.Match(password, "[A-Z]", RegexOptions.IgnoreCase).Success)
            {
                score++;
            }
            if (Regex.Match(password, ".[!,@,#,$,%,^,&,*,?,_,~,-,£,(,)]", RegexOptions.IgnoreCase).Success)
            {
                score++;
            }
            return (PasswordScore)score;
        }
    }
}