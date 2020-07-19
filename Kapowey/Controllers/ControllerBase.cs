using Kapowey.Caching;
using Kapowey.Entities;
using Microsoft.AspNetCore.Identity;
using System;
using System.Threading.Tasks;

namespace Kapowey.Controllers
{
    public abstract class ControllerBase : Microsoft.AspNetCore.Mvc.ControllerBase
    {
        public const string ControllerCacheRegionUrn = "urn:controller_cache";

        private User _currentUser;

        protected ICacheManager CacheManager { get; }

        protected UserManager<User> UserManager { get; }

        protected ControllerBase(
            ICacheManager cacheManager,
            UserManager<User> userManager)
        {
            CacheManager = cacheManager;
            UserManager = userManager;
        }

        protected async Task<User> CurrentUser()
        {
            if (_currentUser == null)
            {
                if (User.Identity.IsAuthenticated)
                {
                    _currentUser = await CacheManager.GetAsync($"urn:controller_user:{User.Identity.Name}", async () =>
                    {
                        return await UserManager.GetUserAsync(User).ConfigureAwait(false);
                    }, ControllerCacheRegionUrn).ConfigureAwait(false);
                }
            }
            if (_currentUser == null)
            {
                throw new UnauthorizedAccessException("Access Denied");
            }
            return _currentUser;
        }
    }
}