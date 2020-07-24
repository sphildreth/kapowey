using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class SeriesCategoryInfo : EntityBase
    {
        [Required]
        [StringLength(500)]
        public string Name { get; set; }

        public SeriesCategoryInfo ParentSeries { get; set; }

        [JsonIgnore]
        public int ParentSeriesCategoryId { get; set; }

        [JsonIgnore]
        public int SeriesCategoryId { get; set; }

        [Required]
        [StringLength(10)]
        public string ShortName { get; set; }
    }
}