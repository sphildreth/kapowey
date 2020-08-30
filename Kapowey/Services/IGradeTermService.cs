using API = Kapowey.Models.API.Entities;

namespace Kapowey.Services
{
    public interface IGradeTermService : IApiEntityService<API.GradeTerm>, IApiEntityListService<API.GradeTerm>
    {
    }
}