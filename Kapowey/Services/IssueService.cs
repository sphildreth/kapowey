using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NodaTime;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class IssueService : ServiceBase, IIssueService
    {
        public ILogger<IssueService> Logger { get; set; }

        public IssueService(
            IOptions<AppSettings> appSettings,
            ILogger<IssueService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.Issue>> ByIdAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Issue.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Issue>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Issue>(data.Adapt<API.Issue>());
        }

        public Task<IPagedResponse<API.IssueInfo>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();
        Task<IServiceResponse<API.Issue>> IIssueService.ByIdAsync(Entities.User user, Guid apiKey) => throw new NotImplementedException();
        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey) => throw new NotImplementedException();
        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Issue issue) => throw new NotImplementedException();
        public Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Issue create) => throw new NotImplementedException();
    }
}
