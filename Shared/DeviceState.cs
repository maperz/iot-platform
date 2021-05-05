namespace Shared
{
    public class DeviceState
    {
        public string DeviceId { get; set; }
        
        public DeviceInfo Info { get; set; }
        
        public bool Connected { get; set; }
        public double? Speed { get; set; }
    }
}