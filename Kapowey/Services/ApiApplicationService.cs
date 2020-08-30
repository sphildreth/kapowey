using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;
using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class ApiApplicationService : ServiceBase, IApiApplicationService
    {
        public ILogger<ApiApplicationService> Logger { get; set; }

        public ApiApplicationService(
            IOptions<AppSettings> appSettings,
            ILogger<ApiApplicationService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public Task<IPagedResponse<API.ApiApplication>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public Task<IServiceResponse<API.ApiApplication>> ByIdAsync(Entities.User user, Guid apiKeyToGet) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.ApiApplication modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.ApiApplication createModel) => throw new NotImplementedException();
    }
}