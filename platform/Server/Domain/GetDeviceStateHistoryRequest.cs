using System;
using System.Collections.Generic;
using MediatR;
using Shared;

namespace Server.Domain
{
    public class GetDeviceStateHistoryRequest: HubRequest, IRequest<IEnumerable<DeviceState>>
    {
        public string DeviceId { get; set; } = "";
        
        public DateTime? Start { get; set; }

        public DateTime? End { get; set; }
        
        public int? IntervalSeconds { get; set; }
        
        public int? Count { get; set; }
    }
}