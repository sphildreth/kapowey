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

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKeyToDelete) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.GradeTerm modifyModel) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.GradeTerm createModel) => throw new NotImplementedException();

        public async Task<IPagedResponse<API.GradeTerm>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();
    }
}