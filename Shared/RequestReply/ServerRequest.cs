using System;

namespace Shared.RequestReply
{    
#nullable disable
    public class ServerRequest<TRequestType, TResponseType>
    {
        public Guid RequestId { get; set; }
        
        public TRequestType Request { get; set; }
    }
    
#nullable enable
}