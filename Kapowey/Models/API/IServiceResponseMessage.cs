using System;
using System.Linq;

namespace Kapowey.Models.API
{
    public interface IServiceResponseMessage
    {
        string Message { get; }
        ServiceResponseMessageType MessageType { get; }
    }
}
