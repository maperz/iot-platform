using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Hosting;
using Shared;

namespace Hub
{
    public class HubBroadcaster : BackgroundService, IApiListener
    {
        private readonly IHubContext<GatewayHub> _hubContext;
        
        public HubBroadcaster(IHubContext<GatewayHub> hubContext, IApiBroadcaster apiBroadcaster)
        {
            _hubContext = hubContext;
            apiBroadcaster.ConnectListener(this);
        }

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            return _hubContext.Clients.All.SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            return Task.CompletedTask;
        }
    }
}