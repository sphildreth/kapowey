using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("persisted_grant")]
    public partial class PersistedGrant
    {
        [Key]
        [Column("key")]
        [StringLength(200)]
        public string Key { get; set; }

        [Required]
        [Column("type")]
        [StringLength(50)]
        public string Type { get; set; }

        [Column("subject_id")]
        [StringLength(200)]
        public string SubjectId { get; set; }

        [Required]
        [Column("client_id")]
        [StringLength(200)]
        public string ClientId { get; set; }

        [Column("creation_time")]
        public DateTime CreationTime { get; set; }

        [Column("expiration")]
        public Instant? Expiration { get; set; }

        [Required]
        [Column("data")]
        [StringLength(50000)]
        public string Data { get; set; }
    }
}