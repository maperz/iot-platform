using System.Collections.Generic;
using System.Reflection;
using System.Threading.Tasks;
using EmpoweredSignalR;
using Microsoft.AspNetCore.SignalR;
using Shared;

namespace Server.Connection
{
    public class GatewayConnection : IApiMethods
    {
        private readonly string _connectionId;
        private readonly string _address;
        private readonly string _hubId;

        private readonly IHubContext<ServerHub> _context;
        
        public GatewayConnection(string connectionId, string address, string hubId, IHubContext<ServerHub> context)
        {
            _connectionId = connectionId;
            _address = address;
            _context = context;
            _hubId = hubId;
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

        public string GetHubId()
        {
            return _hubId;
        }

        public Task<ConnectionInfo> GetConnectionInfo()
        {
            var version = GetType()
                .Assembly
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "";

            var info = new ConnectionInfo()
            {
                IsConnected = true,
                IsProxy = true,
                ProxiedAddress = _address,
                Version = version
            };

            return Task.FromResult(info);
        }
    }
}