using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Shared;

namespace Hub
{
    public class DeviceChangeBroadcaster : IDeviceChangeBroadcaster
    {
        private readonly IHubContext<GatewayHub> _hubContext;
        
        public DeviceChangeBroadcaster(IHubContext<GatewayHub> hubContext)
        {
            _hubContext = hubContext;
        }
        
        public Task BroadcastDeviceStatesChange(IEnumerable<DeviceState> deviceStates)
        {
            return _hubContext.Clients.All.SendAsync(ClientEndpoints.DeviceStateChangedEndpoint, deviceStates);
        }
    }
}