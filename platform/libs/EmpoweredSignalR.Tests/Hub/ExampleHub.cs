using System.Threading.Tasks;
using EmpoweredSignalR.Tests.Client;

namespace EmpoweredSignalR.Tests.Hub
{
    public abstract class ExampleHub : EmpoweredHub
    {
        public async Task MakePingRequest()
        {
            await Clients.InvokeBidirectional<EmptyObject>(Context.ConnectionId, nameof(MockReceiver.Ping));
        }
        
        public async Task<string> MakeToUpperRequest(string text)
        {
            var request = new TextMessage
            {
                Text = text
            };

            var response =
                await Clients.InvokeBidirectional<TextMessage>(Context.ConnectionId, nameof(MockReceiver.ToUpper),
                    request);

            return response.Text;
        }
    }
}