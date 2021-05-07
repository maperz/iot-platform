using System;
using System.Collections.Generic;
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
        private readonly IDeviceService _deviceService;
        private readonly ILogger<GatewayHub> _logger;
        
        public GatewayHub(IMediator mediator, IDeviceService deviceService, ILogger<GatewayHub> logger)
        {
            _mediator = mediator;
            _deviceService = deviceService;
            _logger = logger;
        }

        public override Task OnConnectedAsync()
        {
            _logger.LogDebug("SignalR Client connected {ClientId}", Context.ConnectionId);
            return base.OnConnectedAsync();
        }

        public override Task OnDisconnectedAsync(Exception? exception)
        {
            _logger.LogDebug("SignalR Client disconnected {ClientId}", Context.ConnectionId);
            return base.OnDisconnectedAsync(exception);
        }
        
        // INPUT

        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            var currentStates = await _deviceService.GetDeviceStates();
            return currentStates;
        }

        public Task SetSpeed(string deviceId, double speed)
        {
            // TODO: Get actual device id
            return _mediator.Send(new SetSpeedRequest() { DeviceId = deviceId, Speed = speed });
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            return _mediator.Send(new SetNameRequest() { DeviceId = deviceId, Name = name });
        }
        
    }
}