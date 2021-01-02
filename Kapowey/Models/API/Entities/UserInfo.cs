using FluentValidation;
using Kapowey.Extensions;
using Kapowey.Models.Configuration;
using Kapowey.Services;
using Kapowey.Utility;
using Mapster;
using NodaTime;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class UserInfo : EntityBase
    {
        [AdaptIgnore]
        [JsonIgnore]
        public IEnumerable<Claim> Claims { get; set; } = Enumerable.Empty<Claim>();

        [JsonIgnore]
        public override Instant? CreatedDate { get; set; }

        [Required]
        [DataType(DataType.EmailAddress)]
        [StringLength(256)]
        public string Email { get; set; }

        [AdaptIgnore]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [AdaptIgnore]
        [JsonIgnore]
        public IEnumerable<string> Roles { get; set; } = Enumerable.Empty<string>();

        [JsonIgnore]
        public int UserId { get; set; }

        [Required]
        [StringLength(256)]
        public string UserName { get; set; }

        public string AvatarUrl { get; set; }

        public string PathToImage(IAppSettings settings)
        {
            var folder = settings.UserImageFolder;
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
            return Path.Combine(folder, $"{ ApiKey }.png");
        }

        public static string CacheRegionUrn(Guid Id) => string.Format("urn:user:{0}", Id);
    }

    public sealed class UserInfoValidator : AbstractValidator<UserInfo>
    {
        public UserInfoValidator()
        {
            RuleFor(p => p.UserName)
                .NotEmpty()
                .MaximumLength(255)
                .WithMessage("Please provide a valid user name");

            RuleFor(p => p.Email)
                .NotEmpty()
                .EmailAddress()
                .MaximumLength(255)
                .WithMessage("Please provide a valid Email address");

            RuleFor(x => x.Password)
                .Must(password => UserService.IsNewPasswordStrongEnough(password))
                .WithMessage("Password is not strong enough, try making it longer, numbers or special characters.");
        }
    }
}