using Kapowey.Utility;
using System;

namespace Kapowey.Services.Models
{
    public interface IKapoweyHttpContext
    {
        string BaseUrl { get; set; }

        Uri ImageBaseUri { get; set; }

        public string MakePathForTypeAndId(UriPathType type, Guid id);
    }
}