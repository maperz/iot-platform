using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using System.Text.Json;

namespace EmpoweredSignalR
{
    public static class SenderExtension
    {
        public static Task<TResponse> InvokeBidirectional<TResponse>(this IClientProxy client, String endpoint, TimeSpan? timeOut = null)
        {
            return client.InvokeBidirectional<TResponse>(endpoint, new EmptyObject(), timeOut);
        }
        
        public static async Task<TResponse> InvokeBidirectional<TResponse>(this IClientProxy client, String endpoint, object arg, TimeSpan? timeOut = null)
        {
            var requestGuid = Guid.NewGuid();
            var payload = JsonSerializer.Serialize(arg);

            var request = new BidirectionalMessage { Id = requestGuid, Payload = payload, Endpoint = endpoint};
            
            var manager = OpenRequestManager.Instance;
            
            var resultTask = manager.CreateOpenRequest<TResponse>(request, timeOut);

            await client.SendAsync(nameof(Receiver.OnBidirectionalRequest), request);

            return await resultTask;
        }
    }
}