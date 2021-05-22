using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Reflection;
using System.Threading;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Shared;
using Shared.RequestReply;

namespace Server
{
    class HubConnectionInfo
    {
        public string Id { get; set; } = "";
        public string Address { get; set; } = "";
    }
    
    public class ServerHub : Hub, IApiMethods, IApiListener, IServerMethods
    {
        private readonly ILogger<ServerHub> _logger;
        private readonly IGatewayConnectionManager _connectionManager;

        private static readonly SemaphoreSlim Lock = new(1);
        private static HubConnectionInfo? _singleConnectionInfo;
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

            await Lock.WaitAsync();
            try
            {
                if (_connectionManager.RemoveConnection(connectionId))
                {
                    await SetHubConnectionInfo(null, null);
                    await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
                }
            }
            finally
            {
                Lock.Release();
            }
            
            await base.OnDisconnectedAsync(exception);
        }
        
        
        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            _logger.LogInformation("GetDeviceList called");
            
            // TODO: Support multiple gateways
            var connectionInfo = await GetConnectionIdForUser();

            var connection = _connectionManager.GetConnection(connectionInfo.Id);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            return await connection.GetDeviceList();
        }

        public async Task SendRequest(string deviceId, string name, string payload)
        {
            _logger.LogInformation("SendRequest called with [{DeviceId}, {Name}]", deviceId, name);
            
            // TODO: Support multiple gateways
            var connectionInfo = await GetConnectionIdForUser();

            var connection = _connectionManager.GetConnection(connectionInfo.Id);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            await connection.SendRequest(deviceId, name, payload);
        }

        public async Task ChangeDeviceName(string deviceId, string name)
        {
            _logger.LogInformation("ChangeDeviceName called with [{DeviceId}, {Name}]", deviceId, name);

            var connectionInfo = await GetConnectionIdForUser();

            var connection = _connectionManager.GetConnection(connectionInfo.Id);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            await connection.ChangeDeviceName(deviceId, name);
        }

        public async Task<ConnectionInfo> GetConnectionInfo()
        {
            var connectionInfo = await TryGetConnectionInfo();

            var isConnected = false;
            string? proxiedAddress = null;
            
            if (connectionInfo != null)
            {
                var connection = _connectionManager.GetConnection(connectionInfo.Id);
                isConnected = connection != null;
                proxiedAddress = connection != null ? connectionInfo.Address : null;
            }
            
            var info = new ConnectionInfo()
            {
                IsConnected = isConnected,
                IsProxy = true,
                ProxiedAddress = proxiedAddress,
                Version = GetVersion()
            };

            return info;
        }

        public async Task RegisterAsGateway()
        {
            _logger.LogInformation("Gateway registered with {ConnectionId}", Context.ConnectionId);
            var connectionId = Context.ConnectionId;
            
            var ip = Context.Features.Get<IHttpConnectionFeature>().RemoteIpAddress;
            
            _connectionManager.AddConnection(connectionId);

            await SetHubConnectionInfo(connectionId, ip?.ToString());
            
            await Groups.RemoveFromGroupAsync(connectionId, "clients");
            await Groups.AddToGroupAsync(connectionId, "gateways");

            await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
        }

        public async Task Reply(RawMessage rawMessage)
        {
            _logger.LogInformation("Received Reply for type {Type}", rawMessage.PayloadType);

            
            var connectionInfo = await GetConnectionIdForUser();
          
            // const string connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnection(connectionInfo.Id);
            connection?.RequestSink.OnRequestReply(rawMessage);
        }

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            _logger.LogInformation("Sending Device State change to clients");
            return Clients.Group("clients").SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }

        private string GetVersion()
        {
            return GetType()
                .Assembly
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "";
        }

        private async Task<HubConnectionInfo> GetConnectionIdForUser()
        {
            var info = await TryGetConnectionInfo();
            if (info == null)
            {
                throw new NoConnectionException();
            }

            return info;
        }
        
        private async Task<HubConnectionInfo?> TryGetConnectionInfo()
        {
            await Lock.WaitAsync();
            try
            {
                return _singleConnectionInfo;
            }
            finally
            {
                Lock.Release();
            }
        }
        
        private async Task SetHubConnectionInfo(string? connectionId, string? ip)
        {
            await Lock.WaitAsync();
            try
            {
                if (connectionId == null || ip == null)
                {
                    _singleConnectionInfo = null;
                }
                else
                {
                    _singleConnectionInfo = new HubConnectionInfo()
                    {
                        Id = connectionId,
                        Address = ip
                    };
                }
            }
            finally
            {
                Lock.Release();
            }
        }
    }
}