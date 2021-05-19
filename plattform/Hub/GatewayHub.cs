using System;
using System.Collections.Generic;
using System.Reflection;
using System.Threading.Tasks;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub
{
    public class GatewayHub : Microsoft.AspNetCore.SignalR.Hub, IApiMethods
    {
        private readonly IMediator _mediator;
        private readonly ILogger<GatewayHub> _logger;

        public GatewayHub(IMediator mediator, ILogger<GatewayHub> logger)
        {
            _mediator = mediator;
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            _logger.LogDebug("SignalR Client connected {ClientId}", Context.ConnectionId);

            await Clients.Caller.SendAsync(nameof(ConnectionInfo), await GetConnectionInfo());
            
            await base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception? exception)
        {
            _logger.LogDebug("SignalR Client disconnected {ClientId}", Context.ConnectionId);
            return base.OnDisconnectedAsync(exception);
        }
        
        // INPUT

        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            var deviceList = await _mediator.Send(new GetDeviceListRequest());

            return deviceList;
        }
        
        public Task SendRequest(string deviceId, string name, string payload)
        {
            return _mediator.Send(new SendDeviceRequest() { DeviceId = deviceId, Name = name, Payload = payload});
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            return _mediator.Send(new SetNameRequest() { DeviceId = deviceId, Name = name });
        }

        public Task<ConnectionInfo> GetConnectionInfo()
        {
            var versionInfo = GetType().Assembly
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                ?.InformationalVersion ?? "";
            
            var info = new ConnectionInfo()
            {
                IsConnected = true,
                IsProxy = false,
                ProxiedAddress = null,
                Version = versionInfo
            };
            
            return Task.FromResult(info);
        }
    }
}