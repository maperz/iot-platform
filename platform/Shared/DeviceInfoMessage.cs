#nullable disable

namespace Shared
{
    public record DeviceInfo
    {
        public string Name { get; set; }
        
        public string Type { get; set; }
        
        public string Version { get; set; }
    }
}