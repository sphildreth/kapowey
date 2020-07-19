using FluentValidation;
using Kapowey.Services;
using Mapster;
using NodaTime;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    /// <summary>
    /// Minimum User record used by most API operations and returned as most User property values (like CreatedByUser, ModifiedByUser, etc.)
    /// </summary>
    [Serializable]
    public class UserInfo
    {
        [JsonIgnore]
        public int UserId { get; set; }

        [JsonPropertyName("id")]
        public Guid? ApiKey { get; set; }

        public string UserName { get; set; }

        [AdaptIgnore]
        public string Password { get; set; }

        public string Email { get; set; }

        [JsonIgnore]
        public Instant? CreatedDate { get; set; }

        public Instant? ModifiedDate { get; set; }

        [AdaptIgnore]
        [JsonIgnore]
        public IEnumerable<Claim> Claims { get; set; } = Enumerable.Empty<Claim>();

        [AdaptIgnore]
        [JsonIgnore]
        public IEnumerable<string> Roles { get; set; } = Enumerable.Empty<string>();
    }

    public sealed class UserInfoValidator : AbstractValidator<UserInfo>
    {
        public UserInfoValidator()
        {
            RuleFor(p => p.UserName)
                .NotEmpty()
                .MaximumLength(255)
                .WithMessage("Please provider a valid user name");

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