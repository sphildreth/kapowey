using System.Collections.Generic;

namespace Kapowey.Models.API
{
    public interface IResponse
    {
        bool IsSuccess { get; }
        IEnumerable<IServiceResponseMessage> Messages { get; }
    }
}