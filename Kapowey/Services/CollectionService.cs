using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using Kapowey.Models.Configuration;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class CollectionService : ServiceBase, ICollectionService, ICollectionIssueService
    {
        public ILogger<CollectionService> Logger { get; set; }

        public CollectionService(
            IAppSettings appSettings,
            ILogger<CollectionService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public Task<IPagedResponse<API.Collection>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public async Task<IServiceResponse<API.Collection>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.Collection.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Collection>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Collection>(data.Adapt<API.Collection>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Collection modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.Collection createModel) => throw new NotImplementedException();

        Task<IPagedResponse<CollectionIssueInfo>> IApiEntityListService<CollectionIssueInfo>.ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        Task<IServiceResponse<API.CollectionIssue>> IApiEntityService<API.CollectionIssue>.ByIdAsync(Entities.User user, Guid apiKeyToGet) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.CollectionIssue modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.CollectionIssue createModel) => throw new NotImplementedException();
    }
}