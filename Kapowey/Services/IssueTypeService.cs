using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class IssueTypeService : ServiceBase, IIssueTypeService
    {
        public ILogger<IssueTypeService> Logger { get; set; }

        public IssueTypeService(
            IOptions<AppSettings> appSettings,
            ILogger<IssueTypeService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<IssueTypeInfo>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.IssueType.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.IssueTypeInfo>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.IssueTypeInfo>(data.Adapt<API.IssueTypeInfo>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();
        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, IssueTypeInfo modifyModel) => throw new NotImplementedException();
        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, IssueTypeInfo createModel) => throw new NotImplementedException();
        public Task<IPagedResponse<IssueTypeInfo>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();
    }
}
