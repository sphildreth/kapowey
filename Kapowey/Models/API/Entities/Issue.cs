using Mapster;
using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class Issue : IssueInfo
    {
        [Required]
        [StringLength(3)]
        public string CountryCode { get; set; }

        public int? GcdId { get; set; }

        [StringLength(25)]
        public string ISBN { get; set; }

        [AdaptIgnore]
        public Enums.Rating Rating { get; set; }

        [AdaptIgnore]
        public IssueInfo ReprintOfIssue { get; set; }

        public int ReprintOfIssueId { get; set; }

        [StringLength(500)]
        public string VariantTitle { get; set; }
    }
}