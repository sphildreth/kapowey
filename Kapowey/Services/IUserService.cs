using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IUserService : IApiEntityService<User>, IApiEntityListService<UserInfo>
    {
        Task<IServiceResponse<int>> Register(UserInfo user);

        Task<IServiceResponse<AuthenticateResponse>> AuthenticateAsync(AuthenticateRequest request);
    }
}