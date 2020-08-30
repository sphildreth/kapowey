using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IIssueService : IApiEntityService<API.Issue>, IApiEntityListService<API.IssueInfo>
    {
    }
}