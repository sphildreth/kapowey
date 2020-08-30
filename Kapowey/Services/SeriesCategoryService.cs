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
    public sealed class SeriesCategoryService : ServiceBase, ISeriesCategoryService
    {
        public ILogger<SeriesCategoryService> Logger { get; set; }

        public SeriesCategoryService(
            IOptions<AppSettings> appSettings,
            ILogger<SeriesCategoryService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public Task<IPagedResponse<API.SeriesCategory>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public async Task<IServiceResponse<API.SeriesCategory>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.SeriesCategory.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.SeriesCategory>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.SeriesCategory>(data.Adapt<API.SeriesCategory>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.SeriesCategory modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.SeriesCategory createModel) => throw new NotImplementedException();
    }
}