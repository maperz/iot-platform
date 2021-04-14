using System.Collections.Generic;
using System.Threading.Tasks;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Shared;

namespace Hub
{
    public class GatewayHub : Microsoft.AspNetCore.SignalR.Hub, IApiMethods, IApiListener
    {
        private readonly IMediator _mediator;
        private readonly IDeviceService _deviceService;

        public GatewayHub(IMediator mediator, IDeviceService deviceService, IApiBroadcaster broadcaster)
        {
            _mediator = mediator;
            _deviceService = deviceService;

            broadcaster.ConnectListener(this);
        }
        
        public override async Task OnConnectedAsync()
        {
            var currentStates = await _deviceService.GetDeviceStates();
            await Clients.All.SendAsync(nameof(IApiListener.DeviceStateChanged), currentStates);
        }
        
        // INPUT

        public Task SetSpeed(string deviceId, double speed)
        {
            // TODO: Get actual device id
            return _mediator.Send(new SetSpeedRequest() { DeviceId = deviceId, Speed = speed });
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            return _mediator.Send(new SetNameRequest() { DeviceId = deviceId, Name = name });
        }
        
        // OUTPUT
        
        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            return Clients.All.SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }
    }
}