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
    public sealed class PublisherService : ServiceBase, IPublisherService
    {
        public ILogger<PublisherService> Logger { get; set; }

        public PublisherService(
            IOptions<AppSettings> appSettings,
            ILogger<PublisherService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.Publisher>> ByIdAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Publisher.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Publisher>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Publisher>(data.Adapt<API.Publisher>());
        }

        public async Task<IPagedResponse<API.Publisher>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.Publisher>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Publisher, API.Publisher>(DbContext.Publisher, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteUserAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Publisher.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.Publisher.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Publisher `{ data }`.");
            return new ServiceResponse<bool>(true);
        }
    }
}