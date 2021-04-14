using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Shared;

namespace Server
{
    public class ServerHub : Hub, IApiMethods
    {
        private readonly ILogger<ServerHub> _logger;
        
        public ServerHub(ILogger<ServerHub> logger)
        {
            _logger = logger;
        }
        
        public Task SetSpeed(string deviceId, double speed)
        {
            _logger.LogInformation("SetSpeed called wit [{Double}]", speed);
            // TODO: Find correct client - for now send it to all connected
            return Clients.All.SendAsync(nameof(IApiMethods.SetSpeed), deviceId, speed);
        }

        public Task ChangeDeviceName(string deviceId, string name)
        {
            return Clients.All.SendAsync(nameof(IApiMethods.ChangeDeviceName), deviceId, name);
        }
    }
}