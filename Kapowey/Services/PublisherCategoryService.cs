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

        public async Task<IPagedResponse<API.PublisherCategory>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.PublisherCategory>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.PublisherCategory, API.PublisherCategory>(DbContext.PublisherCategory, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<API.PublisherCategory>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.PublisherCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.PublisherCategory>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.PublisherCategory>(data.Adapt<API.PublisherCategory>());
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.PublisherCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.PublisherCategory.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Publisher Category `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.PublisherCategory modify)
        {
            var data = await DbContext.PublisherCategory.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.ParentPublisherCategoryId = null;
            if (modify?.ParentPublisherCategory?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, modify.ParentPublisherCategory.ApiKey.Value).ConfigureAwait(false);
                data.ParentPublisherCategoryId = parent.Data.PublisherCategoryId;
            }
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.ShortName = modify.ShortName;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            data.Url = modify.Url;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.PublisherCategory create)
        {
            var data = new Entities.PublisherCategory
            {
                ApiKey = Guid.NewGuid(),
                Description = create.Description,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                Name = create.Name,
                ShortName = create.ShortName,
                Status = (int)Enums.Status.New,
                Tags = create.Tags,
                Url = create.Url
            };
            if (create?.ParentPublisherCategory?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, create.ParentPublisherCategory.ApiKey.Value).ConfigureAwait(false);
                data.ParentPublisherCategoryId = parent.Data.PublisherCategoryId;
            }
            await DbContext.PublisherCategory.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}