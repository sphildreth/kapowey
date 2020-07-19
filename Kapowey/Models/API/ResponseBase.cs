using System.Collections.Generic;
using System.Linq;

namespace Kapowey.Models.API
{
    public abstract class ResponseBase
    {
        public bool IsSuccess => Messages?.Any(x => x.MessageType == ServiceResponseMessageType.Ok) ?? true;

        public IEnumerable<IServiceResponseMessage> Messages { get; }

        public ResponseBase(IServiceResponseMessage message)
           : this(new IServiceResponseMessage[1] { message })
        {
        }

        public ResponseBase(IEnumerable<IServiceResponseMessage> messages)
        {
            Messages = messages;
        }
    }
}