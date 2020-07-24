using Kapowey.Models.API;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface ISeriesService
    {
        Task<IPagedResponse<API.Series>> ListAsync(Entities.User user, PagedRequest request);

        Task<IServiceResponse<API.Series>> ByIdAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Series series);

        Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Series create);
    }
}