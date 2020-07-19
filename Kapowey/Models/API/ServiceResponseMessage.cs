using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kapowey.Models.API
{
    public sealed class ServiceResponseMessage : IServiceResponseMessage
    {
        public ServiceResponseMessageType MessageType { get; }
        public string Message { get; }

        public ServiceResponseMessage(string message)
            :this(message, ServiceResponseMessageType.Ok)
        {
        }

        public ServiceResponseMessage(ServiceResponseMessageType messageType)
            : this(null, messageType)
        {
        }

        public ServiceResponseMessage(string message, ServiceResponseMessageType messageType)
        {
            Message = message;
            MessageType = messageType;
        }
    }
}
