using Kapowey.Enums;
using NodaTime;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("IssueType")]
    public partial class IssueType
    {
        public IssueType()
        {
            Issue = new HashSet<Issue>();
        }

        [Key]
        [Column("IssueType_id")]
        public int IssueTypeId { get; set; }

        [Required]
        [Column("name")]
        [StringLength(500)]
        public string Name { get; set; }

        [Required]
        [Column("abbreviation")]
        [StringLength(2)]
        public string Abbreviation { get; set; }

        [Column("description")]
        public string Description { get; set; }

        [Column("api_key")]
        public Guid? ApiKey { get; set; }

        [Column("tags")]
        public string[] Tags { get; set; }

        [Column("created_date", TypeName = "timestamp with time zone")]
        public Instant? CreatedDate { get; set; }

        [Column("created_user_id")]
        public int? CreatedUserId { get; set; }

        [Column("modified_date", TypeName = "timestamp with time zone")]
        public Instant? ModifiedDate { get; set; }

        [Column("modified_user_id")]
        public int? ModifiedUserId { get; set; }

        [Column("reviewed_date", TypeName = "timestamp with time zone")]
        public Instant? ReviewedDate { get; set; }

        [Column("reviewed_user_id")]
        public int? ReviewedUserId { get; set; }

        [Column("status")]
        public int Status { get; set; }

        [NotMapped]
        public Status StatusValue
        {
            get => (Status)Status;
            set => Status = (int)value;
        }

        [ForeignKey(nameof(CreatedUserId))]
        [InverseProperty(nameof(User.IssueTypeCreatedUser))]
        public virtual User CreatedUser { get; set; }

        [ForeignKey(nameof(ModifiedUserId))]
        [InverseProperty(nameof(User.IssueTypeModifiedUser))]
        public virtual User ModifiedUser { get; set; }

        [ForeignKey(nameof(ReviewedUserId))]
        [InverseProperty(nameof(User.IssueTypeReviewedUser))]
        public virtual User ReviewedUser { get; set; }

        [InverseProperty("IssueType")]
        public virtual ICollection<Issue> Issue { get; set; }
    }
}