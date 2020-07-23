using Kapowey.Models.API;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IPublisherService
    {
        Task<IServiceResponse<API.Publisher>> ByIdAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> DeleteUserAsync(Entities.User user, Guid apiKey);

        Task<IPagedResponse<API.Publisher>> ListAsync(Entities.User user, PagedRequest request);
    }
}