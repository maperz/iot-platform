using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR;
using Shared;

namespace Server
{
    public class GatewayConnectionManager : IGatewayConnectionManager
    {
        private Dictionary<string, IGatewayConnection> _connections = new ();

        private readonly IHubContext<ServerHub> _context;

        public GatewayConnectionManager(IHubContext<ServerHub> context)
        {
            _context = context;
        }
        
        public void AddConnection(string connectionId)
        {
            if (_connections.ContainsKey(connectionId))
            {
                return;
            }
            
            _connections.Add(connectionId, new GatewayConnection(connectionId, _context));
        }

        public void RemoveConnection(string connectionId)
        {
            _connections.Remove(connectionId);
        }

        public IGatewayConnection GetConnection(string connectionId)
        {
            return _connections[connectionId];
        }
    }
}