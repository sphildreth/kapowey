using Mapster;
using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class FranchiseCategory : EntityBase
    {
        [Required]
        [StringLength(500)]
        public string Name { get; set; }

        [AdaptIgnore]
        public FranchiseCategory ParentCategory { get; set; }

        [JsonIgnore]
        public int ParentFranchiseCategoryId { get; set; }

        [JsonIgnore]
        public int SeriesCategoryId { get; set; }

        [Required]
        [StringLength(10)]
        public string ShortName { get; set; }
    }
}