using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Enums;
using Kapowey.Extensions;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.Configuration;
using Kapowey.Services.Models;
using Mapster;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Net.Http.Headers;
using NodaTime;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class UserService : ServiceBase, IUserService
    {
        private const string _userRegionKey = "urn:region:users";
        private const string _userByUserNameKey = "urn:user:username:{0}";
        private const string _userByUserIdKey = "urn:user:by:id:{0}";
        private const string _userByUserApiKey = "urn:user:by:apiKey:{0}";

        private IJwtService JwtService { get; }

        private IPasswordHasher<User> PasswordHasher { get; }

        private ILogger<UserService> Logger { get; }

        private IImageService ImageService { get; }

        public UserService(
            IAppSettings appSettings,
            ILogger<UserService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IJwtService jwtService,
            IPasswordHasher<User> passwordHasher,
            IImageService imageService)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            JwtService = jwtService;
            PasswordHasher = passwordHasher;
            ImageService = imageService;
        }

        private Task<int?> GetUserIdForUserName(string userName) => CacheManager.GetAsync(_userByUserNameKey.ToCacheKey(userName), () => GetUserIdForUserNameAction(userName), _userRegionKey);

        private Task<int?> GetUserIdForUserApiKey(Guid? apiKey) => apiKey == null ? null : CacheManager.GetAsync(_userByUserApiKey.ToCacheKey(apiKey), () => GetUserIdForUserApiKeyAction(apiKey.Value), _userRegionKey);

        private Task<User> GetUserById(int userId) => CacheManager.GetAsync(_userByUserIdKey.ToCacheKey(userId), () => GetUserByUserIdAction(userId), _userRegionKey);

        private async Task<User> GetUserByApiKey(Guid? apiKey) => await GetUserById(await GetUserIdForUserApiKey(apiKey).ConfigureAwait(false) ?? 0).ConfigureAwait(false);

        private Task<int?> GetUserIdForUserNameAction(string userName)
        {
            return DbContext.User
                            .Where(x => x.UserName == userName)
                            .Select(x => (int?)x.Id)
                            .FirstOrDefaultAsync();
        }

        private Task<int?> GetUserIdForUserApiKeyAction(Guid apiKey)
        {
            return DbContext.User
                            .Where(x => x.ApiKey == apiKey)
                            .Select(x => (int?)x.Id)
                            .FirstOrDefaultAsync();
        }

        private Task<User> GetUserByUserIdAction(int userId)
        {
            return DbContext.User
                            .Include(x => x.Claims)
                            .Include(x => x.UserUserRole).ThenInclude(x => x.UserRole).ThenInclude(x => x.Claims)
                            .FirstOrDefaultAsync(x => x.Id == userId);
        }

        public async Task<IServiceResponse<AuthenticateResponse>> AuthenticateAsync(AuthenticateRequest request)
        {
            var userId = await GetUserIdForUserName(request.Username).ConfigureAwait(false) ?? 0;
            var user = await GetUserById(userId).ConfigureAwait(false);

            if (user == null)
            {
                return new ServiceResponse<AuthenticateResponse>(new ServiceResponseMessage("Invalid User", ServiceResponseMessageType.Authentication));
            }
            switch (PasswordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password))
            {
                case PasswordVerificationResult.Success:
                    var apiUser = user.Adapt<API.UserInfo>();
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

        public Task<IFileOperationResponse<IImage>> GetUserAvatarImageAsync(Guid id, int width, int height, EntityTagHeaderValue etag = null)
        {
            return ImageService.GetImageAsyncAction(ImageType.UserAvatar, API.User.CacheRegionUrn(id), id, width, height, async () =>
            {
                var userData = await GetUserByApiKey(id).ConfigureAwait(false);
                if (userData == null)
                {
                    return null;
                }
                var user = userData.Adapt<API.User>();
                IImage image = new Image(id)
                {
                    CreatedDate = user.CreatedDate.Value
                };
                var userImageFilename = user.PathToImage(AppSettings);
                try
                {
                    if (File.Exists(userImageFilename))
                    {
                        image.Bytes = File.ReadAllBytes(userImageFilename);
                    }
                }
                catch (Exception ex)
                {
                    Logger.LogError(ex, $"Error Reading Image File [{userImageFilename}]");
                }
                return image;
            }, etag);
        }

        public async Task<IServiceResponse<API.User>> ByIdAsync(User user, Guid apiKey)
        {
            var userData = await GetUserByApiKey(apiKey).ConfigureAwait(false);
            if (userData == null)
            {
                return new ServiceResponse<API.User>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.User>(userData.Adapt<API.User>());
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

        public async Task<IServiceResponse<Guid>> AddAsync(User user, API.User add)
        {
            var data = add.Adapt<User>();
            data.ApiKey = Guid.NewGuid();
            data.CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            await DbContext.Users.AddAsync(data).ConfigureAwait(false);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            CacheManager.Clear();
            Logger.LogWarning($"User `{ user }` add: User `{ data }`.");
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(User user, Guid apiKey)
        {
            var userToDelete = await GetUserByApiKey(apiKey).ConfigureAwait(false);
            if (userToDelete == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.User.Remove(userToDelete);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            CacheManager.Clear();
            Logger.LogWarning($"User `{ user }` deleted: User `{ userToDelete }`.");
            return new ServiceResponse<bool>(true);
        }

        public static bool IsNewPasswordStrongEnough(string password)
        {
            return (CheckPasswordStrength(password)) switch
            {
                PasswordScore.Medium or PasswordScore.Strong or PasswordScore.VeryStrong => true,
                _ => false,
            };
        }

        public async Task<IPagedResponse<API.UserInfo>> ListAsync(User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.UserInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<User, API.UserInfo>(DbContext.User, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(User user, API.User modify)
        {
            var data = await GetUserByApiKey(modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            if (data.ConcurrencyStamp != modify.ConcurrencyStamp)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage("Invalid ConcurrencyStamp", ServiceResponseMessageType.Validation));
            }
            data.Status = Enums.Status.Edited;
            data.UserName = modify.UserName;
            data.NormalizedUserName = modify.UserName.ToUpper();
            if (!String.Equals(data.Email, modify.Email))
            {
                data.Email = modify.Email;
                data.NormalizedEmail = modify.Email.ToUpper();
                data.EmailConfirmed = false;
            }
            if (!String.Equals(data.PhoneNumber, modify.PhoneNumber))
            {
                data.PhoneNumber = modify.PhoneNumber;
                data.PhoneNumberConfirmed = false;
            }
            data.TwoFactorEnabled = modify.TwoFactorEnabled;
            data.LockoutEnabled = modify.LockoutEnabled;
            data.LockoutEnd = modify.LockoutEnd;
            data.Tags = modify.Tags;
            data.IsPublic = modify.IsPublic;
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.ConcurrencyStamp = Guid.NewGuid().ToString();
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            CacheManager.ClearRegion(_userRegionKey);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<int>> Register(API.UserInfo model)
        {
            try
            {
                var newUser = new Entities.User
                {
                    UserName = model.UserName,
                    NormalizedUserName = model.UserName.ToUpper(),
                    Email = model.Email,
                    NormalizedEmail = model.Email.ToUpper()
                };
                newUser.PasswordHash = PasswordHasher.HashPassword(newUser, model.Password);
                await DbContext.User.AddAsync(newUser).ConfigureAwait(false);
                await DbContext.SaveChangesAsync().ConfigureAwait(false);
                if (newUser.Id == 1) // First user to register
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
                    if (adminRole == null)
                    {
                        throw new Exception("Unable to add initial user to Admin role");
                    }
                    // Add user as Admin
                    await DbContext.UserUserRole.AddAsync(new UserUserRole
                    {
                        UserId = newUser.Id,
                        RoleId = adminRole.Id
                    }).ConfigureAwait(false);
                    await DbContext.SaveChangesAsync().ConfigureAwait(false);
                }
                CacheManager.Clear();
                return new ServiceResponse<int>(newUser.Id, new ServiceResponseMessage(ServiceResponseMessageType.Ok));
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, nameof(Register), model);
            }
            return new ServiceResponse<int>(new ServiceResponseMessage("An Error has occured", ServiceResponseMessageType.Error));
        }
    }
}