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
    public sealed class GenreService : ServiceBase, IGenreService
    {
        public ILogger<GenreService> Logger { get; set; }

        public GenreService(
            IAppSettings appSettings,
            ILogger<GenreService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.GenreInfo>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.Genre.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.GenreInfo>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.GenreInfo>(data.Adapt<API.GenreInfo>());
        }

        public async Task<IPagedResponse<API.GenreInfo>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.GenreInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Genre, API.GenreInfo>(DbContext.Genre, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Genre.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.Genre.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Genre `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.GenreInfo modify)
        {
            var data = await DbContext.Genre.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.ParentGenreId = null;
            if (modify?.ParentGenre?.ApiKey != null)
            {
                var parentFranchse = await ByIdAsync(user, modify.ParentGenre.ApiKey.Value).ConfigureAwait(false);
                data.ParentGenreId = parentFranchse.Data.GenreId;
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

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.GenreInfo create)
        {
            var data = new Entities.Genre
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
            if (create?.ParentGenre?.ApiKey != null)
            {
                var parentFranchse = await ByIdAsync(user, create.ParentGenre.ApiKey.Value).ConfigureAwait(false);
                data.ParentGenreId = parentFranchse.Data.GenreId;
            }
            await DbContext.Genre.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}