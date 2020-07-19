using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("user_token")]
    public partial class UserToken : IdentityUserToken<int>
    {
        [Key]
        [Column("user_id")]
        public override int UserId { get; set; }

        [Key]
        [Column("login_provider")]
        [StringLength(128)]
        public override string LoginProvider { get; set; }

        [Key]
        [Column("name")]
        [StringLength(128)]
        public override string Name { get; set; }

        [Column("value")]
        public override string Value { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty("UserToken")]
        public virtual User User { get; set; }
    }
}