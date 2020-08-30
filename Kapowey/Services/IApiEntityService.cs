using Kapowey.Models.API;
using System;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IApiEntityService<T>
    {
        Task<IServiceResponse<T>> ByIdAsync(Entities.User user, Guid apiKeyToGet);

        Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete);

        Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, T modifyModel);

        Task<IServiceResponse<Guid>> AddAsync(Entities.User user, T createModel);
    }
}