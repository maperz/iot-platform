using System;

#nullable disable
namespace Shared
{
    public class DeviceState
    {
        public string DeviceId { get; set; }
        
        public DeviceInfo Info { get; set; }
        
        public bool Connected { get; set; }
        
        public string State { get; set; }
        
        public DateTime LastUpdate { get; set; }
    }
}