using Mapster;
using System;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class Series : SeriesInfo
    {
        [Required]
        [StringLength(3)]
        public string CultureCode { get; set; }

        [AdaptIgnore]
        public IssueInfo FirstIssue { get; set; }

        public Guid? FirstIssueId { get; set; }

        public int? GcdId { get; set; }

        [AdaptIgnore]
        public IssueInfo LastIssue { get; set; }

        public Guid? LastIssueId { get; set; }

        [AdaptIgnore]
        public Enums.Rating Rating { get; set; }

        public int? YearBegan { get; set; }

        public int? YearEnd { get; set; }
    }
}