using System;

namespace EmpoweredSignalR
{
    public class BidirectionalMessage
    {
        public Guid Id { get; set; }

        public string Endpoint { get; set; } = "";
        public string Payload { get; set; } = "";
        public string PayloadType { get; set; } = "";
    }
}