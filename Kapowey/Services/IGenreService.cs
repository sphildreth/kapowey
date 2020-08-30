using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IGenreService : IApiEntityService<API.GenreInfo>, IApiEntityListService<API.GenreInfo>
    {
    }
}