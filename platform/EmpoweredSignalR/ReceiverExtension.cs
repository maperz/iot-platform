using Microsoft.AspNetCore.SignalR.Client;

namespace EmpoweredSignalR
{
    public static class ReceiverExtension
    {
        public static HubConnection AddBidirectionalReceiver(this HubConnection connection, Receiver receiver)
        {
            connection.On<BidirectionalMessage>(nameof(Receiver.OnBidirectionalRequest), (request) => receiver.OnBidirectionalRequest(connection, request));
            return connection;
        }
    }
}