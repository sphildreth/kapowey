using Kapowey.Models.API;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IGenreService
    {
        Task<IPagedResponse<API.GenreInfo>> ListAsync(Entities.User user, PagedRequest request);

        Task<IServiceResponse<API.GenreInfo>> ByIdAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.GenreInfo genre);

        Task<IServiceResponse<int>> AddAsync(Entities.User user, API.GenreInfo create);
    }
}