using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR.Client;

namespace Hub
{
    public class ServerConnection
    {
        private HubConnection _hubConnection;
        
        public ServerConnection()
        {
            var serverUrl = "";
            _hubConnection = new HubConnectionBuilder().WithUrl(serverUrl).Build();
        }

        public async Task Connect()
        {
            await _hubConnection.StartAsync();
        }
    }
}