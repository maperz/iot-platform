using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR;

namespace Server.Connection
{
    public class GatewayConnectionManager : IGatewayConnectionManager
    {
        private readonly Dictionary<string, GatewayConnection> _connections = new ();

        private readonly IHubContext<ServerHub> _context;

        public GatewayConnectionManager(IHubContext<ServerHub> context)
        {
            _context = context;
        }
        
        public void AddConnection(string connectionId, string address, string hubId)
        {
            lock(this)
            {
                if (_connections.ContainsKey(connectionId))
                {
                    return;
                }
                
                _connections.Add(connectionId, new GatewayConnection(connectionId, address, hubId, _context));
            }
        }
        
        public bool RemoveConnection(string connectionId)
        {
            lock(this)
            {
                return _connections.Remove(connectionId);
            }
        }

        public GatewayConnection? GetConnection(string connectionId)
        {
            
            lock(this)
            {
                return _connections.GetValueOrDefault(connectionId);
            }
        }
    }
}