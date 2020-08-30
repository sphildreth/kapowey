using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IApiApplicationService : IApiEntityListService<API.ApiApplication>, IApiEntityService<API.ApiApplication>
    {
    }
}