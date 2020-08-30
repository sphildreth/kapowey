using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface ISeriesCategoryService : IApiEntityListService<API.SeriesCategory>, IApiEntityService<API.SeriesCategory>
    {
    }
}
