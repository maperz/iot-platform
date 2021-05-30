namespace Server
{
    public class Connections
    {
        public string DefaultConnection { get; set; } = "";
    }
    
    public class AppSettings
    {
        public int KeepAliveTimeout { get; init; }
        public int HandshakeTimeout { get; init; }

        public Connections ConnectionStrings { get; set; } = new ();
    }
}