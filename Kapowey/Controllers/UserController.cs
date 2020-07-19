using Kapowey.Caching;
using Kapowey.Entities;
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
            var response = await UserService.ListAsync(await CurrentUser(), request ?? new PagedRequest()).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return StatusCode(StatusCodes.Status201Created, response);
        }

        [HttpPatch]
        [Authorize(Policy = "Admin")]
        public async Task<IActionResult> Update([FromBody]JsonPatchDocument<Models.API.Entities.User> patchDoc)
        {
            //https://docs.microsoft.com/en-us/aspnet/core/web-api/jsonpatch?view=aspnetcore-3.1

            //if (patchDoc != null)
            //{
            //    var customer = CreateCustomer();

            //    patchDoc.ApplyTo(customer, ModelState);

            //    if (!ModelState.IsValid)
            //    {
            //        return BadRequest(ModelState);
            //    }

            //    return new ObjectResult(customer);
            //}
            //else
            //{
            //    return BadRequest(ModelState);
            //}
            throw new NotImplementedException();
        }



        [HttpDelete]
        [Route("{apiKey:guid}")]
        [Authorize(Policy = "Admin")]
        public async Task<IActionResult> Delete(Guid apiKey)
        {
            var response = await UserService.DeleteUserAsync(await CurrentUser(), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok();
        }
    }
}