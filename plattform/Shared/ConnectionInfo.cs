namespace Shared
{
    public class ConnectionInfo
    {
        public bool IsConnected { get; set; }
        public bool IsProxy { get; set; }
        public string? ProxiedAddress { get; set; }
        public string Version { get; set; } = "";
    }
}