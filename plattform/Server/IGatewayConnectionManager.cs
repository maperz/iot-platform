using Shared;

namespace Server
{
    public interface IGatewayConnectionManager
    {
        public void AddConnection(string connectionId);

        public bool RemoveConnection(string connectionId);

        public IGatewayConnection? GetConnection(string connectionId);
    }
}