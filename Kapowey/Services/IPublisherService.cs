using Kapowey.Models.API;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IPublisherService
    {
        Task<IPagedResponse<API.Publisher>> ListAsync(Entities.User user, PagedRequest request);

        Task<IServiceResponse<API.Publisher>> ByIdAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Publisher publisher);

        Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Publisher create);
    }
}