using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class IssueTypeInfo : EntityBase
    {
        [Required]
        [StringLength(2)]
        public string Abbreviation { get; set; }

        [JsonIgnore]
        public int IssueTypeId { get; set; }

        [Required]
        [StringLength(500)]
        public string Name { get; set; }
    }
}