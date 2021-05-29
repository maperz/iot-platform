using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using System.Text.Json;

namespace EmpoweredSignalR
{
    public static class SenderExtension
    {
        public static Task<TResponse> InvokeBidirectional<TResponse>(this IHubClients clients, String connectionId, String endpoint, TimeSpan? timeOut = null)
        {
            return clients.InvokeBidirectional<TResponse>(connectionId, endpoint, new EmptyObject(), timeOut);
        }
        
        public static async Task<TResponse> InvokeBidirectional<TResponse>(this IHubClients clients, String connectionId, String endpoint, object arg, TimeSpan? timeOut = null)
        {
            var requestGuid = Guid.NewGuid();
            var payload = JsonSerializer.Serialize(arg);

            var request = new BidirectionalMessage { Id = requestGuid, Payload = payload, Endpoint = endpoint};
            
            var manager = OpenRequestManager.Instance;
            
            var resultTask = manager.CreateOpenRequest<TResponse>(connectionId, request, timeOut);

            await clients.Client(connectionId).SendAsync(nameof(Receiver.OnBidirectionalRequest), request);

            return await resultTask;
        }
    }
}