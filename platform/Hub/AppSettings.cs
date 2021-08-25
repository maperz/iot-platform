namespace Hub
{
    public class AppSettings
    {
        public string ServerAddress { get; set; } = "";
        public int KeepAliveTimeout { get; set; }
        public int HandshakeTimeout { get; set; }

        public string DatabasePath { get; set; } = "";

        public int StateStorageIntervalSeconds { get; set; } = 600; // 10min
        
        public string HubId { get; set; } = "";
    }
}