using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using System;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IUserService
    {
        Task<IServiceResponse<int>> Register(UserInfo user);

        Task<IServiceResponse<AuthenticateResponse>> AuthenticateAsync(AuthenticateRequest request);

        Task<IPagedResponse<UserInfo>> ListAsync(Entities.User user, PagedRequest request);

        Task<IServiceResponse<bool>> DeleteUserAsync(Entities.User user, Guid apiKey);
    }
}