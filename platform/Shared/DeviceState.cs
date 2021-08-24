using System;

#nullable disable
namespace Shared
{
    public record DeviceState
    {
        public string DeviceId { get; set; }
        
        public DeviceInfo Info { get; set; }
        
        public bool Connected { get; set; }
        
        public string State { get; set; }
        
        public DateTime LastUpdate { get; set; }
    }
}