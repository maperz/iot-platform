using System;

namespace Hub.Data.Entities
{
    public record StateEntity
    {
        public long Id { get; set; }
        
        public string DeviceId { get; set; } = "";
        
        public string? State { get; set; }
        
        public DateTime LastUpdate { get; set; }

        public string? Name { get; set; }
        
        public string? Type { get; set; }
        
        public string? Version { get; set; }
    }
}