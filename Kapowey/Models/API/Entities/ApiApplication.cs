using NodaTime;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class ApiApplication : EntityBase
    {
        [Required]
        [StringLength(500)]
        public virtual string Name { get; set; }

        [JsonIgnore]
        public virtual int ApiApplicationId { get; set; }

        [Required]
        [StringLength(10)]
        public virtual string ShortName { get; set; }

        public virtual Instant? LastActivity { get; set; }
    }
}
