using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Reflection;
using Microsoft.AspNetCore.Http.Features;
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

        private static string? _singleTestConnectionId;
        private static string? _singleRemoteConnectionIp;

        public ServerHub(ILogger<ServerHub> logger, IGatewayConnectionManager connectionManager)
        {
            _logger = logger;
            _connectionManager = connectionManager;
        }
        
        public override async Task OnConnectedAsync()
        {
            var connectionId = Context.ConnectionId;
            _logger.LogInformation("SignalR Client connected {ClientId}", connectionId);
            await Groups.AddToGroupAsync(connectionId, "clients");
            
            await Clients.Caller.SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var connectionId = Context.ConnectionId;

            _logger.LogInformation("SignalR Client disconnected {ClientId}", connectionId);
            
            // TODO: Support multiple gateways

            if (_connectionManager.RemoveConnection(connectionId))
            {
                _singleTestConnectionId = null;
                _singleRemoteConnectionIp = null;
                await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
            }
            
            await base.OnDisconnectedAsync(exception);
        }
        
        
        public Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            _logger.LogInformation("GetDeviceList called");
            
            // TODO: Support multiple gateways
            var  connectionId = _singleTestConnectionId;
            
            if (connectionId == null)
            {
                throw new NoConnectionException();
            }
            
            var connection = _connectionManager.GetConnection(connectionId);

            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            return connection.GetDeviceList();
        }

        public Task SendRequest(string deviceId, string name, string payload)
        {
            _logger.LogInformation("SendRequest called with [{DeviceId}, {Name}]", deviceId, name);
            
            // TODO: Support multiple gateways
            var connectionId = _singleTestConnectionId;
            
            if (connectionId == null)
            {
                throw new NoConnectionException();
            }
            
            var connection = _connectionManager.GetConnection(connectionId);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            return connection.SendRequest(deviceId, name, payload);
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            _logger.LogInformation("ChangeDeviceName called with [{DeviceId}, {Name}]", deviceId, name);

            var connectionId = _singleTestConnectionId;
            
            if (connectionId == null)
            {
                throw new NoConnectionException();
            }
            
            var connection = _connectionManager.GetConnection(connectionId);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            return connection.ChangeDeviceName(deviceId, name);
        }

        public Task<ConnectionInfo> GetConnectionInfo()
        {
            var connectionId = _singleTestConnectionId;

            var isConnected = false;
            string? proxiedAddress = null;
            
            if (connectionId != null)
            {
                var connection = _connectionManager.GetConnection(connectionId);
                isConnected = connection != null;
                proxiedAddress = connection != null ? _singleRemoteConnectionIp : null;
            }
            
            var info = new ConnectionInfo()
            {
                IsConnected = isConnected,
                IsProxy = true,
                ProxiedAddress = proxiedAddress,
                Version = GetVersion()
            };
            
            return Task.FromResult(info);
        }

        public async Task RegisterAsGateway()
        {
            _logger.LogInformation("Gateway registered with {ConnectionId}", Context.ConnectionId);
            var connectionId = Context.ConnectionId;
            
            var ip = Context.Features.Get<IHttpConnectionFeature>().RemoteIpAddress;
            _singleRemoteConnectionIp = ip?.ToString() ?? "";
            
            _connectionManager.AddConnection(connectionId);

            _singleTestConnectionId = connectionId;
            await Groups.RemoveFromGroupAsync(connectionId, "clients");
            await Groups.AddToGroupAsync(connectionId, "gateways");

            await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
        }

        public Task Reply(RawMessage rawMessage)
        {
            _logger.LogInformation("Received Reply for type {Type}", rawMessage.PayloadType);

            var connectionId = _singleTestConnectionId;
            
            if (connectionId == null)
            {
                throw new NoConnectionException();
            }
            
            // const string connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnection(connectionId);
            connection?.RequestSink.OnRequestReply(rawMessage);
            return Task.CompletedTask;
        }

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            return Clients.Group("clients").SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }

        private string GetVersion()
        {
            return GetType()
                .Assembly
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "";
        }
    }
}