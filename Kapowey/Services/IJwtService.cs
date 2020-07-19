using Kapowey.Models.API.Entities;
using System;

namespace Kapowey.Services
{
    public interface IJwtService
    {
        string GenerateSecurityToken(UserInfo user);
    }
}
