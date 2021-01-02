using Kapowey.Imaging;

namespace Kapowey.Models.Configuration
{
    public interface IAppSettings
    {
        /// <summary>
        /// If the service is behind a proxy server this the path hostname to use
        /// </summary>
        string BehindProxyHost { get; set; }

        /// <summary>
        /// List of FQDNs seperated by pipe to add as allowed CORS origins.
        /// </summary>
        string CORSOrigins { get; set; }

        /// <summary>
        /// If true then the pathing behind the proxy is using scheme https.
        /// </summary>
        bool UseSSLBehindProxy { get; set; }

        /// <summary>
        /// Full path to use for root folder to hold data.
        /// </summary>
        string StorageFolder { get; set; }

        /// <summary>
        /// This is the phsycial folder of the applications 'wwwroot' content folder (which holds among other things place-holder images).
        /// </summary>
        public string WebRootPath { get; set; }

        /// <summary>
        /// Full path to use to hold user provided images for user accounts.
        /// </summary>
        string UserImageFolder { get; }

        /// <summary>
        /// Perform any checks to ensure that system is setup according to configuration.
        /// </summary>
        void EnsureSetup();

        /// <summary>
        /// Size to serve thumbnail images if no size is given on request.
        /// </summary>
        ImageSize ThumbnailSize { get; set; }        
    }
}