namespace Server.Config
{
    public class ConnectionsConfig
    {
        public int KeepAliveTimeout { get; init; }
        
        public int HandshakeTimeout { get; init; }
    }
}