using Kapowey.Models.Configuration;
using Kapowey.Utility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;

namespace Kapowey.Services.Models
{
    public class KapoweyHttpContext : IKapoweyHttpContext
    {
        public string BaseUrl { get; set; }

        public Uri ImageBaseUri { get; set; }

        public KapoweyHttpContext(IAppSettings appSettings, IUrlHelper urlHelper)
        {
            var scheme = urlHelper.ActionContext.HttpContext.Request.Scheme;
            if (appSettings.UseSSLBehindProxy)
            {
                scheme = "https";
            }

            var host = urlHelper.ActionContext.HttpContext.Request.Host;
            if (!string.IsNullOrEmpty(appSettings.BehindProxyHost))
            {
                host = new HostString(appSettings.BehindProxyHost);
            }

            BaseUrl = $"{scheme}://{host}";
            ImageBaseUri = new Uri($"{BaseUrl}/images");
        }

        public string MakePathForTypeAndId(UriPathType type, Guid id) => $"{ImageBaseUri.AbsoluteUri}/{type}/{id}.png";
    }
}