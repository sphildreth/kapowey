using Microsoft.AspNetCore.Identity;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("user_role")]
    public partial class UserRole : IdentityRole<int>
    {
        public UserRole()
        {
            UserUserRole = new HashSet<UserUserRole>();
        }

        [NotMapped]
        public int UserRoleId => Id;

        [Column("name")]
        [StringLength(256)]
        public override string Name { get; set; }

        [Column("normalized_name")]
        [StringLength(256)]
        public override string NormalizedName { get; set; }

        [Column("concurrency_stamp")]
        public override string ConcurrencyStamp { get; set; }

        public virtual ICollection<IdentityRoleClaim<int>> Claims { get; set; }

        [InverseProperty("UserRole")]
        public virtual ICollection<UserUserRole> UserUserRole { get; set; }
    }
}