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
    public class FranchiseController : ControllerBase
    {
        private IFranchiseService FranchiseService { get; }

        public FranchiseController(
            IFranchiseService franchiseService,
            ICacheManager cacheManager,
            UserManager<User> userManager)
            : base(cacheManager, userManager)
        {
            FranchiseService = franchiseService;
        }

        [HttpGet]
        public async Task<IActionResult> List(PagedRequest request)
        {
            var response = await FranchiseService.ListAsync(await CurrentUser().ConfigureAwait(false), request ?? new PagedRequest()).ConfigureAwait(false);
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
            var response = await FranchiseService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
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
            var response = await FranchiseService.DeleteAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok();
        }

        [HttpPost]
        [Authorize(Policy = "Contributor")]
        public async Task<IActionResult> Add(Models.API.Entities.Franchise franchise)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            var response = await FranchiseService.AddAsync(await CurrentUser().ConfigureAwait(false), franchise).ConfigureAwait(false);
            if (!response.IsSuccess)
            {
                return BadRequest(response.Messages);
            }
            return Ok(response);
        }

        [HttpPatch]
        [Authorize(Policy = "Contributor")]
        [Route("{apiKey:guid}")]
        public async Task<IActionResult> Modify(Guid apiKey, [FromBody] JsonPatchDocument<Models.API.Entities.Franchise> patchDoc)
        {
            if (patchDoc != null)
            {
                var response = await FranchiseService.ByIdAsync(await CurrentUser().ConfigureAwait(false), apiKey).ConfigureAwait(false);
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
                await FranchiseService.ModifyAsync(await CurrentUser().ConfigureAwait(false), response.Data).ConfigureAwait(false);
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