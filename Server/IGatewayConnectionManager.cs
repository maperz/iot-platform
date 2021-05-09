using Shared;

namespace Server
{
    public interface IGatewayConnectionManager
    {
        public void AddConnection(string connectionId);

        public void RemoveConnection(string connectionId);

        public IGatewayConnection GetConnection(string connectionId);
    }
}