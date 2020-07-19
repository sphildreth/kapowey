using Kapowey.Enums;
using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("collection")]
    public partial class Collection
    {
        [Key]
        [Column("collection_id")]
        public int CollectionId { get; set; }

        [Column("user_id")]
        public int? UserId { get; set; }

        [Column("sort_order")]
        public int? SortOrder { get; set; }

        [Column("api_key")]
        public Guid? ApiKey { get; set; }

        [Required]
        [Column("name")]
        [StringLength(500)]
        public string Name { get; set; }

        [Required]
        [Column("short_name")]
        [StringLength(10)]
        public string ShortName { get; set; }

        [Column("description")]
        public string Description { get; set; }

        [Column("tags")]
        public string[] Tags { get; set; }

        [Column("is_public")]
        public bool? IsPublic { get; set; }

        [Column("last_activity", TypeName = "timestamp with time zone")]
        public Instant? LastActivity { get; set; }

        [Column("created_date", TypeName = "timestamp with time zone")]
        public Instant? CreatedDate { get; set; }

        [Column("status")]
        public int Status { get; set; }

        [NotMapped]
        public Status StatusValue
        {
            get => (Status)Status;
            set => Status = (int)value;
        }

        [ForeignKey(nameof(UserId))]
        [InverseProperty("Collection")]
        public virtual User User { get; set; }

        [InverseProperty("Collection")]
        public virtual CollectionIssue CollectionIssue { get; set; }
    }
}