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

        [NotMapped]
        public override int RoleId
        {
            get => UserRoleId;
            set => UserRoleId = value;
        }

        [Key]
        [Column("user_role_id")]
        public int UserRoleId { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty("UserUserRole")]
        public virtual User User { get; set; }

        [NotMapped]
        public virtual UserRole Role
        {
            get => UserRole;
            set => UserRole = value;
        }

        [ForeignKey(nameof(UserRoleId))]
        [InverseProperty("UserUserRole")]
        public virtual UserRole UserRole { get; set; }
    }
}