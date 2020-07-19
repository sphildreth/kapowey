using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kapowey.Entities
{
    [Table("user_device_code")]
    public partial class UserDeviceCode
    {
        [Key]
        [Column("user_code")]
        [StringLength(200)]
        public string UserCode { get; set; }

        [Required]
        [Column("device_code")]
        [StringLength(200)]
        public string DeviceCode { get; set; }

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
        public DateTime Expiration { get; set; }

        [Required]
        [Column("data")]
        [StringLength(50000)]
        public string Data { get; set; }
    }
}