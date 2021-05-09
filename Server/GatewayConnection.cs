using System;
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
            var request = new ServerRequest<Empty, IEnumerable<DeviceState>> { RequestId = new Guid() };
            
            return await _serverRequester.Request(request);
        }

        public Task SetSpeed(string deviceId, double speed)
        {
            return _context.Clients.Client(_connectionId).SendAsync(nameof(IApiMethods.SetSpeed), deviceId, speed);
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