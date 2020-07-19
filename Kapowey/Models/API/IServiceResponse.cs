using System.Collections.Generic;

namespace Kapowey.Models.API
{
    public interface IServiceResponse<T> : IResponse
    {
        T Data { get; }
    }
}