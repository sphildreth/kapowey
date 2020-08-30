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
    public sealed class GenreService : ServiceBase, IGenreService
    {
        public ILogger<GenreService> Logger { get; set; }

        public GenreService(
            IOptions<AppSettings> appSettings,
            ILogger<GenreService> logger,
            ICacheManager cacheManager,
            KapoweyContext dbContext)
             : base(appSettings, cacheManager, dbContext)
        {
            Logger = logger;
        }

        public async Task<IServiceResponse<API.GenreInfo>> ByIdAsync(Entities.User user, Guid apiKeyToGet)
        {
            var data = await DbContext.Genre.FirstOrDefaultAsync(x => x.ApiKey == apiKeyToGet).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.GenreInfo>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKeyToGet }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.GenreInfo>(data.Adapt<API.GenreInfo>());
        }

        public Task<IPagedResponse<API.GenreInfo>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey) => throw new NotImplementedException();

        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, API.GenreInfo genre) => throw new NotImplementedException();

        public Task<IServiceResponse<Guid>> AddAsync(Entities.User user, API.GenreInfo create) => throw new NotImplementedException();
    }
}