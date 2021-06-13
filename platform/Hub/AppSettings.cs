namespace Hub
{
    public class AppSettings
    {
        public string ServerAddress { get; set; } = "";
        public int KeepAliveTimeout { get; set; }
        public int HandshakeTimeout { get; set; }

        public string HubId { get; set; } = "";
    }
}