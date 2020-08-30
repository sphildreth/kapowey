using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Kapowey.Models.API.Entities;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Threading.Tasks;

using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public sealed class GradeService : ServiceBase, IGradeService
    {
        public ILogger<GradeService> Logger { get; set; }

        public GradeService(
            IOptions<AppSettings> appSettings,
            ILogger<GradeService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public Task<IPagedResponse<GradeInfo>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public async Task<IServiceResponse<API.Grade>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.Grade.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.Grade>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.Grade>(data.Adapt<API.Grade>());
        }

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, Kapowey.Models.API.Entities.Grade modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, Kapowey.Models.API.Entities.Grade createModel) => throw new NotImplementedException();
    }
}