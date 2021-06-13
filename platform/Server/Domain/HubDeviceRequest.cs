using System;

namespace Server.Domain
{
    public class HubDeviceRequest : HubRequest
    {
        public string DeviceId { get; set; } = "";
    }
}