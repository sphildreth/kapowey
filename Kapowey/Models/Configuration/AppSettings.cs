using Kapowey.Imaging;
using System;
using System.Diagnostics;
using System.IO;

namespace Kapowey.Models.Configuration
{
    public sealed class AppSettings : IAppSettings
    {
        /// <inheritdoc/>
        public string CORSOrigins { get; set; }

        /// <inheritdoc/>
        public bool UseSSLBehindProxy { get; set; }

        /// <inheritdoc/>
        public string BehindProxyHost { get; set; }

        /// <inheritdoc/>
        public string WebRootPath { get; set; }

        /// <inheritdoc/>
        public string StorageFolder { get; set; } = "%CUR_DIR%\\Kapowey";

        /// <inheritdoc/>
        public ImageSize ThumbnailSize { get; set; }

        /// <inheritdoc/>
        public string UserImageFolder
        {
            get
            {
                return Path.Combine(StorageFolder, "users");
            }
        }

        public AppSettings()
        {
            ThumbnailSize = new ImageSize();
        }

        public void EnsureSetup()
        {
            StorageFolder = StorageFolder.Replace("%CUR_DIR%", Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData))
                                         .Replace("%APPDATA%", Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData));

            if (!Directory.Exists(StorageFolder))
            {
                Directory.CreateDirectory(StorageFolder);
                Trace.WriteLine($"+ Created Storage Folder [{ StorageFolder }]");
            }
            if (!Directory.Exists(UserImageFolder))
            {
                Directory.CreateDirectory(UserImageFolder);
                Trace.WriteLine($"+ Created User Folder [{ UserImageFolder }]");
            }
        }
    }
}