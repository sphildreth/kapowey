using Mapster;
using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    /// <summary>
    /// Minimum Publisher record used by most API operations
    /// </summary>
    [Serializable]
    public class PublisherInfo : EntityBase
    {
        [JsonIgnore]
        public virtual int PublisherId { get; set; }

        [JsonIgnore]
        public virtual int ParentPublisherId { get; set; }

        [AdaptIgnore]
        public virtual PublisherInfo ParentPublisher { get; set; }

        [JsonIgnore]
        public virtual int PublisherCategoryId { get; set; }

        [AdaptIgnore]
        public virtual PublisherCategory Category { get; set; }

        [Required]
        [StringLength(500)]
        public virtual string Name { get; set; }

        [Required]
        [StringLength(10)]
        public virtual string ShortName { get; set; }

        public int FranchiseCount { get; set; }

        public int SeriesCount { get; set; }

        public int IssueCount { get; set; }
    }
}