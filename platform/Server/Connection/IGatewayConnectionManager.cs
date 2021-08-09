namespace Server.Connection
{
    public interface IGatewayConnectionManager
    {
        public void AddConnection(string connectionId, string address, string hubId);

        public bool RemoveConnection(string connectionId);

        public GatewayConnection? GetConnectionByConnectionId(string connectionId);
        public GatewayConnection? GetConnectionByHubId(string hubId);
    }
}