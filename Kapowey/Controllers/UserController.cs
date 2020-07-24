using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Extensions;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace Kapowey.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        private IUserService UserService { get; }

        public UserController(
            IUserService userService,
            ICacheManager cacheManager,
            UserManager<User> userManager)
            : base(cacheManager, userManager)
        {
            UserService = userService;
        }

        [AllowAnonymous]
        [HttpPost("authenticate")]
        public async Task<IActionResult> Authenticate(AuthenticateRequest model)
        {
            var response = await UserService.AuthenticateAsync(model).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok(response);
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register(Models.API.Entities.UserInfo model)
        {
            var response = await UserService.Register(model).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return StatusCode(StatusCodes.Status201Created, response);
        }

        [HttpGet]
        public async Task<IActionResult> List(PagedRequest request)
        {
            var response = await UserService.ListAsync(await CurrentUser().ConfigureAwait(false), request ?? new PagedRequest()).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return StatusCode(StatusCodes.Status201Created, response);
        }

        [HttpPatch]
        [Route("{apiKey:guid}")]
        public async Task<IActionResult> Modify(Guid apiKey, [FromBody] JsonPatchDocument<Models.API.Entities.User> patchDoc)
        {
            if (!User.IsAdmin() && !User.IsUserByApiKey(apiKey))
            {
                return Unauthorized();
            }
            if (patchDoc != null)
            {
                var response = await UserService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
                if (!response.IsSuccess)
                {
                    return BadRequest(response.Messages);
                }
                patchDoc.ApplyTo(response.Data, ModelState);
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }
                await UserService.ModifyAsync(await CurrentUser().ConfigureAwait(false), response.Data).ConfigureAwait(false);
                if (!response.IsSuccess)
                {
                    return BadRequest(response.Messages);
                }
                return Ok(response);
            }
            else
            {
                return BadRequest(ModelState);
            }
        }

        [HttpGet]
        [Route("{apiKey:guid}")]
        public async Task<IActionResult> ById(Guid apiKey)
        {
            if (!User.IsAdmin() && !User.IsUserByApiKey(apiKey))
            {
                return Unauthorized();
            }
            var response = await UserService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok(response);
        }

        [HttpDelete]
        [Route("{apiKey:guid}")]
        [Authorize(Policy = "Admin")]
        public async Task<IActionResult> DeleteById(Guid apiKey)
        {
            var response = await UserService.DeleteAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok();
        }
    }
}