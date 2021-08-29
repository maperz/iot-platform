using System;

namespace Shared
{
    public class ServerHubHistoryRequest
    {
        public string DeviceId { get; set; } = "";
        
        public DateTime? Start { get; set; }

        public DateTime? End { get; set; }
        
        public int? IntervalSeconds { get; set; }
        
        public int? Count { get; set; }
    }
}