using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IPublisherService : IApiEntityService<API.Publisher>, IApiEntityListService<API.PublisherInfo>
    {
    }
}