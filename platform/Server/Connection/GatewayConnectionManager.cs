using System.Collections.Generic;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace Server.Connection
{
    public class GatewayConnectionManager : IGatewayConnectionManager
    {

        private readonly IHubContext<ServerHub> _context;

        private readonly Dictionary<string, GatewayConnection> _connectionIdMap = new ();
        private readonly Dictionary<string, GatewayConnection> _hubIdMap = new ();
        private readonly ILogger<GatewayConnectionManager> _logger;
        
        public GatewayConnectionManager(IHubContext<ServerHub> context, ILogger<GatewayConnectionManager> logger)
        {
            _context = context;
            _logger = logger;
        }
        
        
        public void AddConnection(string connectionId, string address, string hubId)
        {
            lock(this)
            {
                if (_connectionIdMap.ContainsKey(connectionId))
                {
                    _logger.LogWarning("Trying to add connection with CId: '{ConnectionId}' again - Ignoring request", connectionId);
                    return;
                }

                var connection = new GatewayConnection(connectionId, address, hubId, _context);
                _connectionIdMap[connectionId] = connection;
                _hubIdMap[hubId] = connection;
                _logger.LogInformation("Added connection with CId: '{ConnectionId}' for HubId: '{HubId}'", connectionId, hubId);

            }
        }
        
        public bool RemoveConnection(string connectionId)
        {
            lock(this)
            {
                if (!_connectionIdMap.TryGetValue(connectionId, out var connection))
                {
                    _logger.LogWarning("Trying to remove not registered connection with CId: '{ConnectionId}' - Ignoring request", connectionId);
                    return false;
                }
                
                _connectionIdMap.Remove(connectionId);
                _hubIdMap.Remove(connection.GetHubId());
                _logger.LogInformation("Removed connection with CId: '{ConnectionId}' with HubId: '{HubId}'", connectionId, connection.GetHubId());
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