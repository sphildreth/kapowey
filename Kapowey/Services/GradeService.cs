using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
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
    public sealed class GradeService : ServiceBase, IGradeService
    {
        public ILogger<GradeService> Logger { get; set; }

        public GradeService(
            IAppSettings appSettings,
            ILogger<GradeService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IPagedResponse<GradeInfo>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.GradeInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Grade, API.GradeInfo>(DbContext.Grade, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<API.Grade>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.Grade.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Grade>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Grade>(data.Adapt<API.Grade>());
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Grade.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.Grade.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Grade `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, Kapowey.Models.API.Entities.Grade modify)
        {
            var data = await DbContext.Grade.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.Scale = modify.Scale;
            data.SortOrder = modify.SortOrder;
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.Notes = modify.Notes;
            data.IsBasicGrade = modify.IsBasicGrade;
            data.Abbreviation = modify.Abbreviation;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, Kapowey.Models.API.Entities.Grade create)
        {
            var data = new Entities.Grade
            {
                ApiKey = Guid.NewGuid(),
                Abbreviation = create.Abbreviation,
                Description = create.Description,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                IsBasicGrade = create.IsBasicGrade,
                Name = create.Name,
                Notes = create.Notes,
                Scale = create.Scale,
                SortOrder = create.SortOrder,
                Status = (int)Enums.Status.New,
                Tags = create.Tags
            };
            await DbContext.Grade.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}