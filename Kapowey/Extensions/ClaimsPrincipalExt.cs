using System;
using System.Linq;
using System.Security.Claims;

namespace Kapowey.Extensions
{
    public static class ClaimsPrincipalExt
    {
        public static bool IsAdmin(this ClaimsPrincipal user) => user?.IsInRole("Admin") ?? false;

        public static bool IsManager(this ClaimsPrincipal user) => user.IsAdmin() || (user?.IsInRole("Manager") ?? false);

        public static bool IsEditor(this ClaimsPrincipal user) => user.IsManager() || (user?.IsInRole("Editor") ?? false);

        public static bool IsContributor(this ClaimsPrincipal user) => user.IsEditor() || (user?.IsInRole("Contributor") ?? false);

        public static bool IsUserByApiKey(this ClaimsPrincipal user, Guid apiKey)
        {
            if (!(user?.Claims.Any() ?? false))
            {
                return false;
            }
            return !Guid.Equals(apiKey, user.Claims?.FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier)?.Value);
        }
    }
}