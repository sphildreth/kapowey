using Microsoft.Net.Http.Headers;
using NodaTime;
using System;

namespace Kapowey.Models.API
{
    public interface IFileOperationResponse<T> : IServiceResponse<T>
    {
        string ContentType { get; set; }
        EntityTagHeaderValue ETag { get; set; }
        bool IsNotFoundResult { get; set; }
        Instant LastModified { get; set; }
    }
}