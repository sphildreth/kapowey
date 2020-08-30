using Kapowey.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Kapowey.Services.Models
{
    public class HttpContext : IHttpContext
    {
        public string BaseUrl { get; set; }

        public string ImageBaseUrl { get; set; }

        public HttpContext(AppSettings appSettings, IUrlHelper urlHelper)
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
            ImageBaseUrl = $"{BaseUrl}/images";
        }
    }
}