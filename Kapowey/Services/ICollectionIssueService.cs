using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface ICollectionIssueService : IApiEntityListService<API.CollectionIssueInfo>, IApiEntityService<API.CollectionIssue>
    {
    }
}