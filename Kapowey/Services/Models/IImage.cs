using Kapowey.Enums;
using NodaTime;
using System;

namespace Kapowey.Services.Models
{
    public interface IImage
    {
        byte[] Bytes { get; set; }
        string CacheKey { get; }
        string CacheRegion { get; }
        Instant CreatedDate { get; set; }
        Guid Id { get; }
        Instant LastUpdated { get; set; }
        string Signature { get; set; }
        short SortOrder { get; set; }
        Status Status { get; set; }
        string Url { get; set; }

        string ToString();
    }
}