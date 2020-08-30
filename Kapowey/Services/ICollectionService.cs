using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface ICollectionService : IApiEntityListService<API.Collection>, IApiEntityService<API.Collection>
    {
    }
}