namespace Hub.Config
{
    public class ServerConnectionConfig
    {
        public string ServerBaseAddress { get; set; } = "";
        public int KeepAliveTimeout { get; set; } = 15;
        public int HandshakeTimeout { get; set; } = 15;
    }
}