using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;

namespace EmpoweredSignalR
{
    public class EmpoweredHub : Hub
    {
        public Task OnBidirectionalReply(BidirectionalMessage bidirectionalMessage)
        {
            var manager = OpenRequestManager.Instance;
            manager.OnRequestReply(bidirectionalMessage);
            return Task.CompletedTask;
        }

        public override Task OnDisconnectedAsync(Exception? exception)
        {
            var connectionId = Context.ConnectionId;
            var manager = OpenRequestManager.Instance;
            manager.OnClientDisconnect(connectionId);
            return base.OnDisconnectedAsync(exception);
        }
    }
}