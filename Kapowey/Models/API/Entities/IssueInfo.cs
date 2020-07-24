using System;
using System.Text.Json.Serialization;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public class IssueInfo : EntityBase
    {
        [JsonIgnore]
        public virtual int IssueId { get; set; }

        public int SeriesId { get; set; }
    }
}