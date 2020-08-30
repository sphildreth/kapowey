using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class FranchiseCategoryService : ServiceBase, IFranchiseCategoryService
    {
        public ILogger<FranchiseCategoryService> Logger { get; set; }

        public FranchiseCategoryService(
            IOptions<AppSettings> appSettings,
            ILogger<FranchiseCategoryService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.FranchiseCategory>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.FranchiseCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.FranchiseCategory>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.FranchiseCategory>(data.Adapt<API.FranchiseCategory>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.FranchiseCategory modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.FranchiseCategory createModel) => throw new NotImplementedException();

        public Task<IPagedResponse<API.FranchiseCategory>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();
    }
}