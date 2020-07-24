using Kapowey.Enums;
using NodaTime;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    /// <summary>
    /// User detail record
    /// </summary>
    public sealed class User : UserInfo
    {
        [Required]
        public string ConcurrencyStamp { get; set; }

        public override Instant? CreatedDate { get; set; }

        public bool? IsPublic { get; set; }

        public bool? LockoutEnabled { get; set; }

        public Instant? LockoutEnd { get; set; }

        public override Instant? ModifiedDate { get; set; }

        public string PhoneNumber { get; set; }

        public override Status Status { get; set; }

        public bool? TwoFactorEnabled { get; set; }
    }
}