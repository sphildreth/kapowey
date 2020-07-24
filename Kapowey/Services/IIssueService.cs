using Kapowey.Models.API;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IIssueService
    {
        Task<IPagedResponse<API.IssueInfo>> ListAsync(Entities.User user, PagedRequest request);

        Task<IServiceResponse<API.Issue>> ByIdAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey);

        Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Issue issue);

        Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Issue create);
    }
}