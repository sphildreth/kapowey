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
    public sealed class SeriesService : ServiceBase, ISeriesService
    {
        private ILogger<SeriesService> Logger { get; }

        private IIssueService IssueService { get; }

        private IGenreService GenreService { get; }

        public SeriesService(
            IOptions<AppSettings> appSettings,
            ILogger<SeriesService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IIssueService issueService,
            IGenreService genreService)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            IssueService = issueService;
            GenreService = genreService;
        }

        public async Task<IServiceResponse<API.Series>> ByIdAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Series.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Series>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Series>(data.Adapt<API.Series>());
        }

        public async Task<IPagedResponse<API.Series>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.Series>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Series, API.Series>(DbContext.Series, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Series.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.Series.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Series `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Series modify)
        {
            var data = await DbContext.Series.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.CultureCode = modify.CultureCode;
            data.Description = modify.Description;
            if(modify.FirstIssueId.HasValue)
            {
                var firstIssue = await IssueService.ByIdAsync(user, modify.FirstIssueId.Value).ConfigureAwait(false);
                data.FirstIssueId = firstIssue.Data.IssueId;
            }
            if (modify.LastIssueId.HasValue)
            {
                var lastIssue = await IssueService.ByIdAsync(user, modify.LastIssueId.Value).ConfigureAwait(false);
                data.LastIssueId = lastIssue.Data.IssueId;
            }
            data.GcdId = modify.GcdId;
            if (modify.GenreId.HasValue)
            {
                var genre = await GenreService.ByIdAsync(user, modify.GenreId.Value).ConfigureAwait(false);
                data.GenreId = genre.Data.GenreId;
            }
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.SeriesCategoryId = modify.SeriesCategoryId;
            data.ShortName = modify.ShortName;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            data.Url = modify.Url;
            data.YearBegan = modify.YearBegan;
            data.YearEnd = modify.YearEnd;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<int>> AddAsync(Entities.User user, API.Series create)
        {
            var data = new Entities.Series
            {
                ApiKey = Guid.NewGuid(),
                CultureCode = create.CultureCode,
                Description = create.Description,
                GcdId = create.GcdId,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                Name = create.Name,
                Rating = create.Rating,
                ShortName = create.ShortName,
                Status = (int)Enums.Status.New,
                Tags = create.Tags,
                Url = create.Url,
                YearBegan = create.YearBegan,
                YearEnd = create.YearEnd
            };
            if (create.GenreId.HasValue)
            {
                var genre = await GenreService.ByIdAsync(user, create.GenreId.Value).ConfigureAwait(false);
                data.GenreId = genre.Data.GenreId;
            }
            if (create.FirstIssueId.HasValue)
            {
                var firstIssue = await IssueService.ByIdAsync(user, create.FirstIssueId.Value).ConfigureAwait(false);
                data.FirstIssueId = firstIssue.Data.IssueId;
            }
            if (create.LastIssueId.HasValue)
            {
                var lastIssue = await IssueService.ByIdAsync(user, create.LastIssueId.Value).ConfigureAwait(false);
                data.LastIssueId = lastIssue.Data.IssueId;
            }
            await DbContext.Series.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<int>(data.SeriesId);
        }

    }
}