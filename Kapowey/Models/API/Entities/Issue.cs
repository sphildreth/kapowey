using Mapster;
using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class Issue : IssueInfo
    {
        [StringLength(25)]
        public string Barcode { get; set; }

        [Required]
        [StringLength(3)]
        public string CountryCode { get; set; }

        public int? GcdId { get; set; }

        [StringLength(25)]
        public string ISBN { get; set; }

        [AdaptIgnore]
        public IssueTypeInfo IssueType { get; set; }

        public int IssueTypeId { get; set; }

        public Instant? KeyDate { get; set; }

        [StringLength(10)]
        public string Number { get; set; }

        [AdaptIgnore]
        public Enums.Rating Rating { get; set; }

        [AdaptIgnore]
        public IssueInfo ReprintOfIssue { get; set; }

        public int ReprintOfIssueId { get; set; }

        [StringLength(20)]
        public string ShortTitle { get; set; }

        public int SortOrder { get; set; }

        [StringLength(500)]
        public string Title { get; set; }

        [StringLength(500)]
        public string VariantTitle { get; set; }
    }
}