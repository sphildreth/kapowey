using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    public class GradeTerm : EntityBase
    {
        [Required]
        [StringLength(500)]
        public virtual string Name { get; set; }

        [JsonIgnore]
        public int GradeTermId { get; set; }

        public int SortOrder { get; set; }
    }
}