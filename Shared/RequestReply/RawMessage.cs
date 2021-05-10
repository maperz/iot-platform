using System;

namespace Shared.RequestReply
{
    public class RawMessage
    {
        public Guid Id { get; set; }
        public string Payload { get; set; }
        
        public string PayloadType { get; set; }
    }
}