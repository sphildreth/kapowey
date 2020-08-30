using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class PublisherCategoryService : ServiceBase, IPublisherCategoryService
    {
        public ILogger<PublisherCategoryService> Logger { get; set; }

        public PublisherCategoryService(
            IOptions<AppSettings> appSettings,
            ILogger<PublisherCategoryService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public Task<IPagedResponse<API.PublisherCategory>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public async Task<IServiceResponse<API.PublisherCategory>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.PublisherCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.PublisherCategory>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.PublisherCategory>(data.Adapt<API.PublisherCategory>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.PublisherCategory modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.PublisherCategory createModel) => throw new NotImplementedException();
    }
}