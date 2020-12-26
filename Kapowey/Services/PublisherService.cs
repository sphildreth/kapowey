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
    public sealed class PublisherService : ServiceBase, IPublisherService
    {
        public ILogger<PublisherService> Logger { get; set; }

        public IPublisherCategoryService PublisherCategoryService { get; }

        public PublisherService(
            IOptions<AppSettings> appSettings,
            ILogger<PublisherService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IPublisherCategoryService publisherCategoryService)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            PublisherCategoryService = publisherCategoryService;
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

        public async Task<IPagedResponse<API.PublisherInfo>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.PublisherInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Publisher, API.PublisherInfo>(DbContext.Publisher, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
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

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Publisher modify)
        {
            var data = await DbContext.Publisher.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.CountryCode = modify.CountryCode;
            data.Description = modify.Description;
            data.GcdId = modify.GcdId;
            data.PublisherCategoryId = null;
            if (modify?.Category?.ApiKey != null)
            {
                var category = await PublisherCategoryService.ByIdAsync(user, modify.Category.ApiKey.Value).ConfigureAwait(false);
                data.PublisherCategoryId = category.Data.PublisherCategoryId;
            }
            data.ParentPublisherId = null;
            if (modify?.ParentPublisher?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, modify.ParentPublisher.ApiKey.Value).ConfigureAwait(false);
                data.ParentPublisherId = parent.Data.PublisherId;
            }
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.ShortName = modify.ShortName;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            data.Url = modify.Url;
            data.YearBegan = modify.YearBegan;
            data.YearEnd = modify.YearEnd;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.Publisher create)
        {
            var data = new Entities.Publisher
            {
                ApiKey = Guid.NewGuid(),
                CountryCode = create.CountryCode,
                Description = create.Description,
                GcdId = create.GcdId,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                Name = create.Name,
                ShortName = create.ShortName,
                Status = (int)Enums.Status.New,
                Tags = create.Tags,
                Url = create.Url,
                YearBegan = create.YearBegan,
                YearEnd = create.YearEnd
            };
            if (create?.Category?.ApiKey != null)
            {
                var category = await PublisherCategoryService.ByIdAsync(user, create.Category.ApiKey.Value).ConfigureAwait(false);
                data.PublisherCategoryId = category.Data.PublisherCategoryId;
            }
            if (create?.ParentPublisher?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, create.ParentPublisher.ApiKey.Value).ConfigureAwait(false);
                data.ParentPublisherId = parent.Data.PublisherId;
            }
            await DbContext.Publisher.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}