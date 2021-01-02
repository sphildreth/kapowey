using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using Kapowey.Services.Models;
using Microsoft.Net.Http.Headers;
using System;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IUserService : IApiEntityService<User>, IApiEntityListService<UserInfo>
    {
        Task<IServiceResponse<int>> Register(UserInfo user);

        Task<IServiceResponse<AuthenticateResponse>> AuthenticateAsync(AuthenticateRequest request);

        Task<IFileOperationResponse<IImage>> GetUserAvatarImageAsync(Guid id, int width, int height, EntityTagHeaderValue etag = null);
    }
}