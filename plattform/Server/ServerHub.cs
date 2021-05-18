using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Shared;
using Shared.RequestReply;

namespace Server
{
    public class ServerHub : Hub, IApiMethods, IApiListener, IServerMethods
    {
        private readonly ILogger<ServerHub> _logger;
        private readonly IGatewayConnectionManager _connectionManager;

        private static string _singleTestConnectionId;
        
        public ServerHub(ILogger<ServerHub> logger, IGatewayConnectionManager connectionManager)
        {
            _logger = logger;
            _connectionManager = connectionManager;
        }
        
        public override Task OnConnectedAsync()
        {
            var connectionId = Context.ConnectionId;
            _logger.LogInformation("SignalR Client connected {ClientId}", connectionId);
            Groups.AddToGroupAsync(connectionId, "clients");
            return base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception exception)
        {
            var connectionId = Context.ConnectionId;

            _logger.LogInformation("SignalR Client disconnected {ClientId}", connectionId);
            
            // TODO: Support multiple gateways
            
            _connectionManager.RemoveConnection(connectionId);
            return base.OnDisconnectedAsync(exception);
        }
        
        
        public Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            _logger.LogInformation("GetDeviceList called");
            
            // TODO: Support multiple gateways
            var  connectionId = _singleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.GetDeviceList();
        }

        public Task SendRequest(string deviceId, string name, string payload)
        {
            _logger.LogInformation("SendRequest called with [{DeviceId}, {Name}]", deviceId, name);
            
            // TODO: Support multiple gateways
            var connectionId = _singleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.SendRequest(deviceId, name, payload);
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            _logger.LogInformation("ChangeDeviceName called with [{DeviceId}, {Name}]", deviceId, name);

            var connectionId = _singleTestConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            return connection?.ChangeDeviceName(deviceId, name);
        }

        public Task RegisterAsGateway()
        {
            _logger.LogInformation("Gateway registered with {ConnectionId}", Context.ConnectionId);

            var connectionId = Context.ConnectionId;
            _connectionManager.AddConnection(connectionId);

            _singleTestConnectionId = connectionId;
            Groups.RemoveFromGroupAsync(connectionId, "clients");
            Groups.AddToGroupAsync(connectionId, "gateways");

            return Task.CompletedTask;
        }

        public Task Reply(RawMessage rawMessage)
        {
            _logger.LogInformation("Received Reply for type {Type}", rawMessage.PayloadType);

            var connectionId = _singleTestConnectionId;
            // const string connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            connection?.RequestSink.OnRequestReply(rawMessage);
            return Task.CompletedTask;
        }

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            return Clients.Group("clients").SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }
    }
}