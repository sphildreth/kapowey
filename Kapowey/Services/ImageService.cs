using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Enums;
using Kapowey.Extensions;
using Kapowey.Imaging;
using Kapowey.Models.API;
using Kapowey.Models.Configuration;
using Kapowey.Services.Models;
using Kapowey.Utility;
using Microsoft.Extensions.Logging;
using Microsoft.Net.Http.Headers;
using NodaTime;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public class ImageService : ServiceBase, IImageService
    {
        protected IHttpEncoder HttpEncoder { get; }

        private ILogger<ImageService> Logger { get; }

        public ImageService(
            IAppSettings appSettings,
            ILogger<ImageService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IHttpEncoder httpEncoder)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            HttpEncoder = httpEncoder;
        }

        protected FileOperationResponse<IImage> GenerateFileOperationResult(Guid id, IImage image, EntityTagHeaderValue etag = null, string contentType = "image/png")
        {
            var imageEtag = EtagHelper.GenerateETag(HttpEncoder, image.Bytes);
            if (EtagHelper.CompareETag(HttpEncoder, etag, imageEtag))
            {
                return new FileOperationResponse<IImage>(new ServiceResponseMessage(NotModifiedMessage, ServiceResponseMessageType.NotModified));
            }
            if (image?.Bytes?.Any() != true)
            {
                return new FileOperationResponse<IImage>(new ServiceResponseMessage($"ImageById Not Set [{id}]", ServiceResponseMessageType.NotFound));
            }
            return new FileOperationResponse<IImage>(image, new ServiceResponseMessage(ServiceResponseMessageType.Ok))
            {
                ContentType = contentType,
                LastModified = image.CreatedDate,
                ETag = imageEtag
            };
        }

        public async Task<IFileOperationResponse<IImage>> GetImageAsyncAction(ImageType imageType, string regionUrn, Guid id, int width, int height, Func<Task<IImage>> action, EntityTagHeaderValue etag = null)
        {
            try
            {
                var sw = Stopwatch.StartNew();
                var sizeHash = width + height;
                var result = await CacheManager.GetAsync($"urn:{imageType}_by_id_operation:{id}:{sizeHash}", action, regionUrn).ConfigureAwait(false);
                if (result?.Bytes == null)
                {
                    result = DefaultImageForImageType(AppSettings, imageType);
                }
                var data = GenerateFileOperationResult(id, result, etag);
                if (data.ETag == etag && etag != null)
                {
                    return new FileOperationResponse<IImage>(new ServiceResponseMessage(NotModifiedMessage, ServiceResponseMessageType.NotModified));
                }
                if (data?.Data?.Bytes != null)
                {
                    var resized = ImageHelper.ResizeImage(data?.Data?.Bytes, width, height, true);
                    if (resized != null)
                    {
                        data.Data.Bytes = resized.Item2;
                        data.ETag = EtagHelper.GenerateETag(HttpEncoder, data.Data.Bytes);
                        data.LastModified = Instant.FromDateTimeUtc(DateTime.UtcNow);
                        if (resized.Item1)
                        {
                            Logger.LogInformation($"{imageType}: Resized [{id}], Width [{ width}], Height [{ height}]");
                        }
                    }
                    else
                    {
                        Logger.LogInformation($"{imageType}: Image [{id}] Request returned Null Image");
                    }
                }

                sw.Stop();
                return new FileOperationResponse<IImage>(data.Data, data.Messages)
                {
                    ETag = data.ETag,
                    LastModified = data.LastModified,
                    ContentType = data.ContentType
                };
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, $"GetImageFileOperation Error, Type [{imageType}], id [{id}]");
            }

            return new FileOperationResponse<IImage>(new ServiceResponseMessage("System Error", ServiceResponseMessageType.Error));
        }

        private static IImage DefaultImageForImageType(IAppSettings appSettings, ImageType type)
        {
            return type switch
            {
                ImageType.UserAvatar => MakeImageFromFile(MakeImagePath(appSettings, $@"{ appSettings.WebRootPath }\images\user.png")),
                _ => throw new NotImplementedException(),
            };
        }

        private static IImage MakeImageFromFile(string filename)
        {
            if (!File.Exists(filename))
            {
                return new Image();
            }
            var bytes = File.ReadAllBytes(filename);
            return new Image
            {
                Bytes = bytes,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow)
            };
        }

        private static string MakeImagePath(IAppSettings appSettings, string filename)
        {
            if (string.IsNullOrEmpty(filename))
            {
                return null;
            }
            var path = Path.Combine(appSettings.StorageFolder, filename);
            if (!File.Exists(path))
            {
                Trace.WriteLine($"Unable To Find Path [{ path }], ContentPath [{ appSettings.StorageFolder }]");
            }
            return path;
        }
    }
}