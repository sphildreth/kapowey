using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Extensions;
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
    public class PublisherController : ControllerBase
    {
        private IPublisherService PublisherService { get; }

        public PublisherController(
            IPublisherService publisherService,
            ICacheManager cacheManager,
            UserManager<User> userManager)
            : base(cacheManager, userManager)
        {
            PublisherService = publisherService;
        }

        [HttpGet]
        public async Task<IActionResult> List(PagedRequest request)
        {
            var response = await PublisherService.ListAsync(await CurrentUser().ConfigureAwait(false), request ?? new PagedRequest()).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return StatusCode(StatusCodes.Status201Created, response);
        }

        [HttpGet]
        [Route("{apiKey:guid}")]
        public async Task<IActionResult> ById(Guid apiKey)
        {
            var response = await PublisherService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok(response);
        }

        [HttpDelete]
        [Route("{apiKey:guid}")]
        [Authorize(Policy = "Manager")]
        public async Task<IActionResult> DeleteById(Guid apiKey)
        {
            var response = await PublisherService.DeleteAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok();
        }

        [HttpPost]
        [Authorize(Policy ="Contributor")]
        public async Task<IActionResult> Add(Models.API.Entities.Publisher publisher)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var response = await PublisherService.AddAsync(await CurrentUser().ConfigureAwait(false), publisher).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok(response);
        }

        [HttpPatch]
        [Authorize(Policy = "Contributor")]
        [Route("{apiKey:guid}")]
        public async Task<IActionResult> Modify(Guid apiKey, [FromBody]JsonPatchDocument<Models.API.Entities.Publisher> patchDoc)
        {
            if (patchDoc != null)
            {
                var response = await PublisherService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
                if (!response.IsSuccess)
                {
                    return BadRequest(response.Messages);
                }
                // Either the contributor (owner) or a Manager or above 
                if (!User.IsInRole("Manager") && !User.IsUserByApiKey(response.Data.CreatedUser.ApiKey.Value))
                {
                    return Unauthorized();
                }
                patchDoc.ApplyTo(response.Data, ModelState);
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }
                await PublisherService.ModifyAsync(await CurrentUser().ConfigureAwait(false), response.Data).ConfigureAwait(false);
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
    }
}