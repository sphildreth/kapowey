using Kapowey.Models.API;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public interface IApiEntityListService<T>
    {
        Task<IPagedResponse<T>> ListAsync(Entities.User user, PagedRequest request);
    }
}