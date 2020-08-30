using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IIssueTypeService : IApiEntityService<API.IssueTypeInfo>, IApiEntityListService<API.IssueTypeInfo>
    {
    }
}