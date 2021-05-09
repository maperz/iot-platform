using System;

namespace Shared.RequestReply
{
    public class RawMessage
    {
        public Guid Id { get; set; }
        public object? Payload { get; set; }
    }
}