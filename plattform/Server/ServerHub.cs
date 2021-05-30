using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Reflection;
using System.Threading;
using EmpoweredSignalR;
using MediatR;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Server.Connection;
using Server.Domain;
using Shared;

namespace Server
{
    class HubConnectionInfo
    {
        public string Id { get; set; } = "";
        public string Address { get; set; } = "";
    }
    
    public class ServerHub : EmpoweredHub, IApiMethods, IApiListener, IServerMethods
    {
        private readonly ILogger<ServerHub> _logger;
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly IMediator _mediator;
        
        private static readonly SemaphoreSlim Lock = new(1);
        private static HubConnectionInfo? _singleConnectionInfo;
        public ServerHub(ILogger<ServerHub> logger, IMediator mediator, IGatewayConnectionManager connectionManager)
        {
            _logger = logger;
            _mediator = mediator;
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
                await SetHubConnectionInfo(null, null);
                await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
            }
            
            await base.OnDisconnectedAsync(exception);
        }
        
        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            var connectionInfo = await GetConnectionIdForUser();
            return await _mediator.Send(new GetDeviceListRequest() {HubId = connectionInfo.Id});
        }

        public async Task SendRequest(string deviceId, string name, string payload)
        {
            var connectionInfo = await GetConnectionIdForUser();
            await _mediator.Send(new SendHubDeviceRequest()
                {HubId = connectionInfo.Id, DeviceId = deviceId, Name = name, Payload = payload});
        }

        public async Task ChangeDeviceName(string deviceId, string name)
        {
            var connectionInfo = await GetConnectionIdForUser();
            await _mediator.Send(new SetNameRequest()
                {HubId = connectionInfo.Id, DeviceId = deviceId, Name = name});
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
            
            var version = GetType()
                .Assembly
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "";
            
            var info = new ConnectionInfo()
            {
                IsConnected = isConnected,
                IsProxy = true,
                ProxiedAddress = proxiedAddress,
                Version = version
            };

            return info;
        }

        public async Task RegisterAsGateway(string id)
        {
            _logger.LogInformation("Gateway registered with Id: {Id}, and CId: {ConnectionId}", id, Context.ConnectionId);
            var connectionId = Context.ConnectionId;
            
            var ip = Context.Features.Get<IHttpConnectionFeature>().RemoteIpAddress;
            
            _connectionManager.AddConnection(connectionId);
            await SetHubConnectionInfo(connectionId, ip?.ToString());
            await Groups.RemoveFromGroupAsync(connectionId, "clients");
            await Groups.AddToGroupAsync(connectionId, "gateways");
            await Clients.Group("clients").SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
        }

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            _logger.LogInformation("Sending Device State change to clients");
            return Clients.Group("clients").SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
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