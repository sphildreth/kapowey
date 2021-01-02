using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models.API;
using Kapowey.Models.Configuration;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using NodaTime;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class SeriesCategoryService : ServiceBase, ISeriesCategoryService
    {
        public ILogger<SeriesCategoryService> Logger { get; set; }

        public SeriesCategoryService(
            IAppSettings appSettings,
            ILogger<SeriesCategoryService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IPagedResponse<API.SeriesCategory>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.SeriesCategory>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.SeriesCategory, API.SeriesCategory>(DbContext.SeriesCategory, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<API.SeriesCategory>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.SeriesCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.SeriesCategory>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.SeriesCategory>(data.Adapt<API.SeriesCategory>());
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.SeriesCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.SeriesCategory.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Series Category `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.SeriesCategory modify)
        {
            var data = await DbContext.SeriesCategory.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.ParentSeriesCategoryId = null;
            if (modify?.ParentSeriesCategory?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, modify.ParentSeriesCategory.ApiKey.Value).ConfigureAwait(false);
                data.ParentSeriesCategoryId = parent.Data.SeriesCategoryId;
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

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.SeriesCategory create)
        {
            var data = new Entities.SeriesCategory
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
            if (create?.ParentSeriesCategory?.ApiKey != null)
            {
                var parent = await ByIdAsync(user, create.ParentSeriesCategory.ApiKey.Value).ConfigureAwait(false);
                data.ParentSeriesCategoryId = parent.Data.SeriesCategoryId;
            }
            await DbContext.SeriesCategory.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}