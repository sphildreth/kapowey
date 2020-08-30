using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IFranchiseCategoryService : IApiEntityService<API.FranchiseCategory>, IApiEntityListService<API.FranchiseCategory>
    {
    }
}