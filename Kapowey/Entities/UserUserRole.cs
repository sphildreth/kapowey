using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("user_user_role")]
    public partial class UserUserRole : IdentityUserRole<int>
    {
        [Key]
        [Column("user_id")]
        public override int UserId { get; set; }

        [Key]
        [Column("user_role_id")]
        public override int RoleId { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty("UserUserRole")]
        public virtual User User { get; set; }

        [NotMapped]
        public virtual UserRole Role
        {
            get => UserRole;
            set => UserRole = value;
        }

        [ForeignKey(nameof(RoleId))]
        [InverseProperty("UserUserRole")]
        public virtual UserRole UserRole { get; set; }
    }
}