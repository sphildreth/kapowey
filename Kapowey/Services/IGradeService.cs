using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IGradeService : IApiEntityListService<API.GradeInfo>, IApiEntityService<API.Grade>
    {
    }
}