using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
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
    public sealed class IssueTypeService : ServiceBase, IIssueTypeService
    {
        public ILogger<IssueTypeService> Logger { get; set; }

        public IssueTypeService(
            IOptions<AppSettings> appSettings,
            ILogger<IssueTypeService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<IssueTypeInfo>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.IssueType.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.IssueTypeInfo>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.IssueTypeInfo>(data.Adapt<API.IssueTypeInfo>());
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.IssueType.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.IssueType.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Issue Type `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, IssueTypeInfo modify)
        {
            var data = await DbContext.IssueType.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            data.ModifiedDate = Instant.FromDateTimeUtc(DateTime.UtcNow);
            data.ModifiedUserId = user.Id;
            data.Name = modify.Name;
            data.Abbreviation = modify.Abbreviation;
            data.Status = (int)Enums.Status.Edited;
            data.Tags = modify.Tags;
            var modified = await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<bool>(modified > 0);
        }

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, IssueTypeInfo create)
        {
            var data = new Entities.IssueType
            {
                ApiKey = Guid.NewGuid(),
                Description = create.Description,
                CreatedDate = Instant.FromDateTimeUtc(DateTime.UtcNow),
                CreatedUserId = user.Id,
                Name = create.Name,
                Abbreviation = create.Abbreviation,
                Status = (int)Enums.Status.New,
                Tags = create.Tags
            };
            await DbContext.IssueType.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }

        public async Task<IPagedResponse<IssueTypeInfo>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<IssueTypeInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.IssueType, API.IssueTypeInfo>(DbContext.IssueType, request).ConfigureAwait(false);
        }
    }
}