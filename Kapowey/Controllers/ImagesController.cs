using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Extensions;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.Configuration;
using Kapowey.Services;
using Kapowey.Services.Models;
using Kapowey.Utility;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Net.Http.Headers;
using NodaTime;
using System;
using System.Net;
using System.Threading.Tasks;

namespace Kapowey.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ImagesController : ControllerBase
    {
        private IUserService UserService { get; }

        private IAppSettings AppSettings { get; }

        public ImagesController(
            ICacheManager cacheManager,
            UserManager<User> userManager,
            IUserService userService,
            IAppSettings appSettings)
            : base(cacheManager, userManager)
        {
            UserService = userService;
            AppSettings = appSettings;
        }

        [HttpGet("user/{id}.png/{width:int?}/{height:int?}/{cacheBuster?}")]
        [ProducesResponseType(200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> UserAvatarImage(Guid id, int? width, int? height)
        {
            var result = await UserService.GetUserAvatarImageAsync(id, width ?? AppSettings.ThumbnailSize.Width, height ?? AppSettings.ThumbnailSize.Height).ConfigureAwait(false);
            if (result?.IsNotFoundResult != false)
            {
                return NotFound();
            }
            if (!result.IsSuccess)
            {
                return StatusCode((int)HttpStatusCode.InternalServerError);
            }
            return MakeFileResult(result.Data.Bytes, $"{id}.jpg", result.ContentType, result.LastModified.ToDateTimeOffset(), result.ETag);
        }

        private IActionResult MakeFileResult(byte[] bytes, string fileName, string contentType, DateTimeOffset? lastModified, EntityTagHeaderValue eTag) => File(bytes, contentType, fileName, lastModified, eTag);


    }
}
