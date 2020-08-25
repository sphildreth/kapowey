using Kapowey.Entities;
using Kapowey.Enums;
using Newtonsoft.Json;
using NodaTime;
using System;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class CollectionIssue : CollectionIssueInfo
    {
        public Instant? LastActivityDate { get; set; }

        public Instant? AcquisitionDate { get; set; }

        public bool IsForSale { get; set; }

        public bool HasRead { get; set; }

        public bool IsWanted { get; set; }

        public bool IsDigital { get; set; }

        public int NumberOfCopiesOwned { get; set; }

        public string Notes { get; set; }

    }
}