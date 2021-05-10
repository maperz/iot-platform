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

        private static string SingleTestConnectionId;
        
        public ServerHub(ILogger<ServerHub> logger, IGatewayConnectionManager connectionManager)
        {
            _logger = logger;
            _connectionManager = connectionManager;
        }
        
        public override Task OnConnectedAsync()
        {
            _logger.LogInformation("SignalR Client connected {ClientId}", Context.ConnectionId);
            return base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception exception)
        {
            _logger.LogInformation("SignalR Client disconnected {ClientId}", Context.ConnectionId);
            
            // TODO: Support multiple gateways
            
            var connectionId = Context.ConnectionId;
            _connectionManager.RemoveConnection(connectionId);
            
            return base.OnDisconnectedAsync(exception);
        }
        
        
        public Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            _logger.LogInformation("GetDeviceList called");
            
            // TODO: Support multiple gateways
            var  connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.GetDeviceList();
        }

        public Task SetSpeed(string deviceId, double speed)
        {
            _logger.LogInformation("SetSpeed called with [{Double}]", speed);
            
            // TODO: Support multiple gateways
            var connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.SetSpeed(deviceId, speed);
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            _logger.LogInformation("ChangeDeviceName called with [{DeviceId}, {Name}]", deviceId, name);

            var connectionId = SingleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.ChangeDeviceName(deviceId, name);
        }

        public Task RegisterAsGateway()
        {
            _logger.LogInformation("Gateway registered with {ConnectionId}", Context.ConnectionId);

            var connectionId = Context.ConnectionId;
            _connectionManager.AddConnection(connectionId);

            SingleTestConnectionId = connectionId;
            
            return Task.CompletedTask;
        }

        public Task Reply(RawMessage rawMessage)
        {
            _logger.LogInformation("Received Reply for type {Type}", rawMessage.PayloadType);

            var connectionId = SingleTestConnectionId;
            // const string connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            connection?.RequestSink.OnRequestReply(rawMessage);
            return Task.CompletedTask;
        }
    }
}