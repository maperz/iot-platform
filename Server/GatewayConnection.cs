using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Server.RequestReply;
using Shared;
using Shared.RequestReply;

namespace Server
{
    public class GatewayConnection : IGatewayConnection
    {
        private readonly string _connectionId;
        private readonly IHubContext<ServerHub> _context;
        private readonly ServerRequester _serverRequester;
        
        public GatewayConnection(string connectionId, IHubContext<ServerHub> context)
        {
            _connectionId = connectionId;
            _context = context;
            
            _serverRequester = new ServerRequester(connectionId, context);
        }
        
        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            var request = new DeviceListRequest();
            return await _serverRequester.Request(request);
        }

        public Task SendRequest(string deviceId, string name, string payload)
        {
            return _context.Clients.Client(_connectionId).SendAsync(nameof(IApiMethods.SendRequest), deviceId, name, payload);
        }
        
        public Task ChangeDeviceName(string deviceId, string name)
        {
            return _context.Clients.Client(_connectionId).SendAsync(nameof(IApiMethods.ChangeDeviceName), deviceId, name);
        }

        public IServerRequesterSink RequestSink {
            get => _serverRequester;
        }
    }
}