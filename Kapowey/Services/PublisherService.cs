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
            data.PublisherCategoryId = modify.PublisherCategoryId;
            data.ParentPublisherId = modify.ParentPublisherId;
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

        public async Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Publisher create)
        {
            var data = new Entities.Publisher
            {
                ApiKey = Guid.NewGuid(),
                CountryCode = create.CountryCode,
                Description = create.Description,
                GcdId = create.GcdId,
                PublisherCategoryId = create.PublisherCategoryId,
                ParentPublisherId = create.ParentPublisherId,
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
            await DbContext.Publisher.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<int>(data.PublisherId);
        }
    }
}