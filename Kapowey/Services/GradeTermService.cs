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
    public sealed class GradeTermService : ServiceBase, IGradeTermService
    {
        public ILogger<GradeTermService> Logger { get; set; }

        public GradeTermService(
            IOptions<AppSettings> appSettings,
            ILogger<GradeTermService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.GradeTerm>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.GradeTerm.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.GradeTerm>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.GradeTerm>(data.Adapt<API.GradeTerm>());
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.GradeTerm.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.GradeTerm.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Grade Term `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.GradeTerm modify)
        {
            var data = await DbContext.GradeTerm.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.SortOrder = modify.SortOrder;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.GradeTerm create)
        {
            var data = new Entities.GradeTerm
            {
                ApiKey = Guid.NewGuid(),
                Description = create.Description,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                Name = create.Name,
                SortOrder = create.SortOrder,
                Status = (int)Enums.Status.New,
                Tags = create.Tags
            };
            await DbContext.GradeTerm.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }

        public async Task<IPagedResponse<API.GradeTerm>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.GradeTerm>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.GradeTerm, API.GradeTerm>(DbContext.GradeTerm, request).ConfigureAwait(false);
        }
    }
}