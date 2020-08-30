using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IFranchiseService : IApiEntityService<API.Franchise>, IApiEntityListService<API.FranchiseInfo>
    {
    }
}