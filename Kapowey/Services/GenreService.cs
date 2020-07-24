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

        public async Task<IServiceResponse<API.GenreInfo>> ByIdAsync(Entities.User user, Guid apiKey)
        {
            var data = await DbContext.Genre.FirstOrDefaultAsync(x => x.ApiKey == apiKey).ConfigureAwait(false);
            if (data == null)
            {
                return new ServiceResponse<API.GenreInfo>(new ServiceResponseMessage($"Invalid ApiKey [{ apiKey }]", ServiceResponseMessageType.NotFound));
            }
            return new ServiceResponse<API.GenreInfo>(data.Adapt<API.GenreInfo>());
        }

        public Task<IPagedResponse<GenreInfo>> ListAsync(Entities.User user, PagedRequest request) => throw new NotImplementedException();
        public Task<IServiceResponse<bool>> DeleteAsync(Entities.User user, Guid apiKey) => throw new NotImplementedException();
        public Task<IServiceResponse<bool>> ModifyAsync(Entities.User user, GenreInfo genre) => throw new NotImplementedException();
        public Task<IServiceResponse<int>> AddAsync(Entities.User user, GenreInfo create) => throw new NotImplementedException();
    }
}
