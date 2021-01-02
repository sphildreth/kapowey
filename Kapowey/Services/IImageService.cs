using Kapowey.Enums;
using Kapowey.Models.API;
using Kapowey.Services.Models;
using Microsoft.Net.Http.Headers;
using System;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IImageService
    {
        Task<IFileOperationResponse<IImage>> GetImageAsyncAction(ImageType imageType, string regionUrn, Guid id, int width, int height, Func<Task<IImage>> action, EntityTagHeaderValue etag = null);
    }
}