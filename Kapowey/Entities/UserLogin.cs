using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("user_login")]
    public partial class UserLogin : IdentityUserLogin<int>
    {
        [Key]
        [Column("login_provider")]
        [StringLength(128)]
        public override string LoginProvider { get; set; }

        [Key]
        [Column("provider_key")]
        [StringLength(128)]
        public override string ProviderKey { get; set; }

        [Column("provider_display_name")]
        public override string ProviderDisplayName { get; set; }

        [Column("user_id")]
        public new int? UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty("UserLogin")]
        public virtual User User { get; set; }
    }
}