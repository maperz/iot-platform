using System.Collections.Generic;
using System.Threading.Tasks;
using EmpoweredSignalR;
using Microsoft.AspNetCore.SignalR;
using Shared;

namespace Server.Connection
{
    public class GatewayConnection : IGatewayConnection
    {
        private readonly string _connectionId;
        private readonly IHubContext<ServerHub> _context;
        
        public GatewayConnection(string connectionId, IHubContext<ServerHub> context)
        {
            _connectionId = connectionId;
            _context = context;
        }
        
        public Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            return _context.Clients.InvokeBidirectional<IEnumerable<DeviceState>>(_connectionId, "GetDeviceStates");
        }

        public Task SendRequest(string deviceId, string name, string payload)
        {
            return _context.Clients.Client(_connectionId).SendAsync(nameof(IApiMethods.SendRequest), deviceId, name, payload);
        }
        
        public Task ChangeDeviceName(string deviceId, string name)
        {
            return _context.Clients.Client(_connectionId).SendAsync(nameof(IApiMethods.ChangeDeviceName), deviceId, name);
        }

        public Task<ConnectionInfo> GetConnectionInfo()
        {
            throw new System.NotImplementedException();
        }
    }
}