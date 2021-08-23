using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR;

namespace Server.Connection
{
    public class GatewayConnectionManager : IGatewayConnectionManager
    {

        private readonly IHubContext<ServerHub> _context;

        private readonly Dictionary<string, GatewayConnection> _connectionIdMap = new ();
        private readonly Dictionary<string, GatewayConnection> _hubIdMap = new ();

        public GatewayConnectionManager(IHubContext<ServerHub> context)
        {
            _context = context;
        }
        
        
        public void AddConnection(string connectionId, string address, string hubId)
        {
            lock(this)
            {
                if (_connectionIdMap.ContainsKey(connectionId))
                {
                    return;
                }

                var connection = new GatewayConnection(connectionId, address, hubId, _context);
                _connectionIdMap[connectionId] = connection;
                _hubIdMap[hubId] = connection;
            }
        }
        
        public bool RemoveConnection(string connectionId)
        {
            lock(this)
            {
                if (!_connectionIdMap.TryGetValue(connectionId, out var connection)) return false;
                
                _connectionIdMap.Remove(connectionId);
                _hubIdMap.Remove(connection.GetHubId());
                return true;

            }
        }

        public GatewayConnection? GetConnectionByConnectionId(string connectionId)
        {
            lock(this)
            {
                return _connectionIdMap.GetValueOrDefault(connectionId);
            }
        }

        public GatewayConnection? GetConnectionByHubId(string hubId)
        {
            lock(this)
            {
                return _hubIdMap.GetValueOrDefault(hubId);
            }
        }
    }
}