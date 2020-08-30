using Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IJwtService
    {
        string GenerateSecurityToken(UserInfo user);
    }
}