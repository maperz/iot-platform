using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Shared;
using Shared.RequestReply;

namespace Server
{
    public class ServerHub : Hub, IApiMethods, IServerMethods
    {
        private readonly ILogger<ServerHub> _logger;
        private readonly IGatewayConnectionManager _connectionManager;

        // For now this is the only gateway connection that exists
        private const string SingleTestConnectionId = "SingleTestId";
        
        public ServerHub(ILogger<ServerHub> logger, IGatewayConnectionManager connectionManager)
        {
            _logger = logger;
            _connectionManager = connectionManager;
        }
        
        public override Task OnConnectedAsync()
        {
            _logger.LogDebug("SignalR Client connected {ClientId}", Context.ConnectionId);
            return base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception exception)
        {
            _logger.LogDebug("SignalR Client disconnected {ClientId}", Context.ConnectionId);
            
            // TODO: Support multiple gateways
            const string  connectionId = SingleTestConnectionId;
            // const string connectionId = Context.ConnectionId;
            _connectionManager.RemoveConnection(connectionId);
            
            return base.OnDisconnectedAsync(exception);
        }
        
        
        public Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            _logger.LogInformation("GetDeviceList called");
            // TODO: Support multiple gateways
            const string  connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.GetDeviceList();
        }

        public Task SetSpeed(string deviceId, double speed)
        {
            _logger.LogInformation("SetSpeed called with [{Double}]", speed);
            // TODO: Find correct client - for now send it to all connected
            
            const string connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.SetSpeed(deviceId, speed);
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            _logger.LogInformation("ChangeDeviceName called with [{DeviceId}, {Name}]", deviceId, name);

            const string connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.ChangeDeviceName(deviceId, name);
        }

        public Task RegisterAsGateway()
        {
            // TODO: Support multiple gateways
            const string  connectionId = SingleTestConnectionId;
            // const string connectionId = Context.ConnectionId;
            _connectionManager.AddConnection(connectionId);
            return Task.CompletedTask;
        }

        public Task Reply(RawMessage rawMessage)
        {
            const string connectionId = SingleTestConnectionId;
            // const string connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            connection?.RequestSink.OnRequestReply(rawMessage.Id, rawMessage.Payload);
            return Task.CompletedTask;
        }
    }
}