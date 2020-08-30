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
    public sealed class FranchiseService : ServiceBase, IFranchiseService
    {
        private ILogger<FranchiseService> Logger { get; }

        private IFranchiseCategoryService FranchiseCategoryService { get; }

        public FranchiseService(
            IOptions<AppSettings> appSettings,
            ILogger<FranchiseService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext,
            IFranchiseCategoryService franchiseCategoryService)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
            FranchiseCategoryService = franchiseCategoryService;
        }

        public async Task<IServiceResponse<API.Franchise>> ByIdAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Franchise.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Franchise>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Franchise>(data.Adapt<API.Franchise>());
        }

        public async Task<IPagedResponse<API.FranchiseInfo>> ListAsync(Entities.User user, PagedRequest request)
        {
            if (!request.IsValid)
            {
                return new PagedResponse<API.FranchiseInfo>(new ServiceResponseMessage("Invalid Request", ServiceResponseMessageType.Error));
            }
            return await CreatePagedResponse<Entities.Franchise, API.FranchiseInfo>(DbContext.Franchise, request).ConfigureAwait(false);
        }

        public async Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Franchise.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            DbContext.Franchise.Remove(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            Logger.LogWarning($"User `{ user }` deleted: Franchise `{ data }`.");
            return new ServiceResponse<bool>(true);
        }

        public async Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.Franchise modify)
        {
            var data = await DbContext.Franchise.FirstOrDefaultAsync(x => x.ApiKey == modify.ApiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<bool>(new ServiceResponseMessage($"Invalid ApiKey [{ modify.ApiKey }]", ServiceResponseMessageType.NotFound));
            }
            data.Description = modify.Description;
            if (modify?.ParentFranchise?.ApiKey != null)
            {
                var parentFranchse = await ByIdAsync(user, modify.ParentFranchise.ApiKey.Value).ConfigureAwait(false);
                data.ParentFranchiseId = parentFranchse.Data.FranchiseId;
            }
            data.GcdId = modify.GcdId;
            if (modify.FranchiseCategory?.ApiKey != null)
            {
                var category = await FranchiseCategoryService.ByIdAsync(user, modify.FranchiseCategory.ApiKey.Value);
                data.FranchiseCategoryId = category.Data.FranchiseCategoryId;
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

        public async Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.Franchise create)
        {
            var data = new Entities.Franchise
            {
                ApiKey = Guid.NewGuid(),
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
            if (create?.ParentFranchise?.ApiKey != null)
            {
                var parentFranchse = await ByIdAsync(user, create.ParentFranchise.ApiKey.Value).ConfigureAwait(false);
                data.ParentFranchiseId = parentFranchse.Data.FranchiseId;
            }
            if (create.FranchiseCategory?.ApiKey != null)
            {
                throw new NotImplementedException();
            }
            await DbContext.Franchise.AddAsync(data);
            await DbContext.SaveChangesAsync().ConfigureAwait(false);
            return new ServiceResponse<Guid>(data.ApiKey.Value);
        }
    }
}