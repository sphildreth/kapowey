using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.API;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;

namespace Kapowey.Services
{
    public abstract class ServiceBase
    {
        protected AppSettings AppSettings { get; }

        protected ICacheManager CacheManager { get; }

        protected KapoweyContext DbContext { get; }

        protected ServiceBase(IOptions<AppSettings> appSettings, ICacheManager cacheManager, KapoweyContext dbContext)
        {
            AppSettings = appSettings.Value;
            CacheManager = cacheManager;
            DbContext = dbContext;
        }

        /// <summary>
        /// Creates a paged set of data for the given Queryable and Request.
        /// </summary>
        /// <typeparam name="T">The type of the source IQueryable.</typeparam>
        /// <typeparam name="TReturn">The type of the returned paged results.</typeparam>
        /// <param name="queryable">The source IQueryable.</param>
        /// <param name="request">Request model.</param>
        /// <returns>Returns a paged set of results.</returns>
        protected async Task<IPagedResponse<TReturn>> CreatePagedResponse<T, TReturn>(IQueryable<T> queryable, PagedRequest request) where T : class
        {
            var filter = request.FilterSql();
            var totalNumberOfRecords = await queryable.Where(filter).CountAsync().ConfigureAwait(false);
            var projection = queryable
                .Where(filter)
                .OrderBy(request.Ordering())
                .Skip(request.Skip)
                .Take(request.PageSize);
            var results = await projection.ProjectToType<TReturn>().ToListAsync().ConfigureAwait(false);
            return new PagedResponse<TReturn>(results)
            {
                PageNumber = request.Page,
                PageSize = results.Count,
                TotalNumberOfPages = (int)Math.Ceiling((double)totalNumberOfRecords / request.PageSize),
                TotalNumberOfRecords = totalNumberOfRecords,
            };
        }
    }
}