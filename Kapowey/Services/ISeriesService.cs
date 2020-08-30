using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface ISeriesService : IApiEntityService<API.Series>, IApiEntityListService<API.SeriesInfo>
    {
    }
}