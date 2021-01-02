using FluentValidation.AspNetCore;
using Kapowey.Caching;
using Kapowey.Entities;
using Kapowey.Models;
using Kapowey.Models.Configuration;
using Kapowey.Services;
using Kapowey.Services.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Formatters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using NodaTime.Serialization.SystemTextJson;
using Npgsql;
using ScottBrady91.AspNetCore.Identity;
using Serilog;
using System;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace Kapowey
{
    public class Startup
    {
        public IWebHostEnvironment Environment { get; }

        public Startup(IConfiguration configuration, IWebHostEnvironment environment)
        {
            Configuration = configuration;
            Environment = environment;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            NpgsqlConnection.GlobalTypeMapper.UseNodaTime();

            IAppSettings settings = new AppSettings();
            Configuration.GetSection("AppSettings").Bind(settings);
            settings.WebRootPath = Environment.WebRootPath;
            settings.EnsureSetup();
            services.AddSingleton<IAppSettings>(settings);

            services.AddSingleton<IActionContextAccessor, ActionContextAccessor>();
            services.AddSingleton<IHttpEncoder, HttpEncoder>();

            services.AddSingleton<ICacheSerializer>(options =>
            {
                var logger = options.GetService<ILogger<Utf8JsonCacheSerializer>>();
                return new Utf8JsonCacheSerializer(logger);
            });

            services.AddSingleton<ICacheManager>(options =>
            {
                var logger = options.GetService<ILogger<MemoryCacheManager>>();
                var serializer = options.GetService<ICacheSerializer>();
                return new MemoryCacheManager(logger, serializer, new CachePolicy(TimeSpan.FromHours(4)));
            });

            services.AddDbContext<KapoweyContext>(options =>
                    options.UseNpgsql(Configuration.GetConnectionString("KapoweyConnectionString"), o => o.UseNodaTime())
                        //   .UseSnakeCaseNamingConvention()
                           .EnableDetailedErrors()                           
                           .EnableSensitiveDataLogging());

            services.AddIdentity<User, UserRole>()
                    .AddRoles<UserRole>()
                    .AddEntityFrameworkStores<KapoweyContext>();

            services.AddScoped<IPasswordHasher<User>, BCryptPasswordHasher<User>>();

            // configure strongly typed settings objects
            var appSettingsSection = Configuration.GetSection("AppSettings");
            services.Configure<AppSettings>(appSettingsSection);

            // configure jwt authentication
            var appSettings = appSettingsSection.Get<AppSettings>();
            var secret = Configuration.GetSection("JwtConfig").GetSection("secret").Value;
            var key = Encoding.ASCII.GetBytes(secret);
            services.AddAuthentication(x =>
            {
                x.DefaultSignInScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(x =>
            {
                x.RequireHttpsMetadata = false;
                x.SaveToken = true;
                x.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = false,
                    ValidateAudience = false
                };
            });

            services.AddAuthorization(options =>
            {
                options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
                options.AddPolicy("Manager", policy => policy.RequireRole("Admin", "Manager"));
                options.AddPolicy("Editor", policy => policy.RequireRole("Admin", "Editor", "Manager"));
                options.AddPolicy("Contributor", policy => policy.RequireRole("Admin", "Contributor", "Editor", "Manager"));
            });

            services.AddHttpContextAccessor();
            services.AddScoped<IKapoweyHttpContext>(factory =>
            {
                var actionContext = factory.GetService<IActionContextAccessor>().ActionContext;
                if (actionContext == null)
                {
                    return null;
                }
                return new KapoweyHttpContext(factory.GetService<IAppSettings>(), new UrlHelper(actionContext));
            });

            services.AddScoped<IImageService, ImageService>();
            services.AddScoped<IJwtService, JwtService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IFranchiseCategoryService, FranchiseCategoryService>();
            services.AddScoped<IFranchiseService, FranchiseService>();
            services.AddScoped<IGenreService, GenreService>();
            services.AddScoped<IGradeService, GradeService>();
            services.AddScoped<IGradeTermService, GradeTermService>();
            services.AddScoped<IPublisherCategoryService, PublisherCategoryService>();
            services.AddScoped<ISeriesCategoryService, SeriesCategoryService>();
            services.AddScoped<IPublisherService, PublisherService>();
            services.AddScoped<ISeriesService, SeriesService>();
            services.AddScoped<IIssueTypeService, IssueTypeService>();
            services.AddScoped<IIssueService, IssueService>();
            services.AddScoped<ICollectionService, CollectionService>();
            services.AddScoped<ICollectionIssueService, CollectionService>();
            services.AddScoped<IApiApplicationService, ApiApplicationService>();

            services.AddControllers(options =>
                {
                    options.InputFormatters.Insert(0, GetJsonPatchInputFormatter());
                })
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.ConfigureForNodaTime(NodaTime.DateTimeZoneProviders.Tzdb);
                    options.JsonSerializerOptions.WithIsoDateIntervalConverter();
                    options.JsonSerializerOptions.WithIsoIntervalConverter();
                    options.JsonSerializerOptions.IgnoreNullValues = true;
                })
                .AddFluentValidation(s =>
                {
                    s.RegisterValidatorsFromAssemblyContaining<Startup>();
                    s.RunDefaultMvcValidationAfterFluentValidationExecutes = false;
                });
        }

        private static NewtonsoftJsonPatchInputFormatter GetJsonPatchInputFormatter()
        {
            var builder = new ServiceCollection()
                .AddLogging()
                .AddMvc()
                .AddNewtonsoftJson()
                .Services.BuildServiceProvider();

            return builder
                .GetRequiredService<IOptions<MvcOptions>>()
                .Value
                .InputFormatters
                .OfType<NewtonsoftJsonPatchInputFormatter>()
                .First();
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            app.UseSerilogRequestLogging();

            // global cors policy
            var settings = new AppSettings();
            Configuration.GetSection("AppSettings").Bind(settings);
            var corsOrigins = (settings.CORSOrigins ?? "http://localhost:5000").Split('|');
            Trace.WriteLine($"Setting Up CORS Policy [{string.Join(", ", corsOrigins)}]");

            app.UseStaticFiles();

            app.UseCors(x => x
                .WithOrigins(corsOrigins)
                .AllowAnyMethod()
                .AllowAnyHeader()
                .SetIsOriginAllowed(origin => true) // allow any origin
                .AllowCredentials());; // allow credential

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints => endpoints.MapControllers());
        }
    }
}