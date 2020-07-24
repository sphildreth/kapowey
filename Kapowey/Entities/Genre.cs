using Kapowey.Enums;
using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("genre")]
    public partial class Genre
    {
        [Key]
        [Column("genre_id")]
        public int GenreId { get; set; }

        [Column("parent_genre_id")]
        public int? ParentGenreId { get; set; }

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

        [Column("url")]
        [StringLength(1000)]
        public string Url { get; set; }

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
        [InverseProperty(nameof(User.GenreCreatedUser))]
        public virtual User CreatedUser { get; set; }

        [ForeignKey(nameof(ModifiedUserId))]
        [InverseProperty(nameof(User.GenreModifiedUser))]
        public virtual User ModifiedUser { get; set; }

        [ForeignKey(nameof(ReviewedUserId))]
        [InverseProperty(nameof(User.GenreReviewedUser))]
        public virtual User ReviewedUser { get; set; }
    }
}