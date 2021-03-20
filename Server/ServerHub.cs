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
        
        public Task SetSpeed(double speed)
        {
            // TODO: Find correct client - for now send it to all connected
            _logger.LogInformation("SetSpeed called wit [{Double}]", speed);
            return Clients.All.SendAsync("SetSpeed", speed);
        }
    }
}