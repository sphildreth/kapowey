using System.Collections.Generic;
using System.Linq;

namespace Kapowey.Models.API
{
    public class ServiceResponse<T> : ResponseBase, IServiceResponse<T>
    {
        public T Data { get; }

        public ServiceResponse(IServiceResponseMessage message)
           :this(default, new IServiceResponseMessage[1] { message })
        {
        }

        public ServiceResponse(IEnumerable<IServiceResponseMessage> messages)
           : this(default, messages)
        {
        }

        public ServiceResponse(T data, IServiceResponseMessage message)
           : this(data, new IServiceResponseMessage[1] { message })
        {
        }

        public ServiceResponse(T data, IEnumerable<IServiceResponseMessage> messages = null)
            :base(messages)
        {
            Data = data;
        }
    }
}