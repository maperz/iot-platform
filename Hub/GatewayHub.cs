using System;
using System.Threading.Tasks;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using MQTTnet.Server;
using Shared;

namespace Hub
{
    public class GatewayHub : Microsoft.AspNetCore.SignalR.Hub, IApiMethods
    {
        private readonly IMediator _mediator;
        public GatewayHub(IMediator mediator)
        {
            _mediator = mediator;
        }
        
        public override async Task OnConnectedAsync()
        {
            await Task.Run(() => Console.WriteLine("New client connected"));
            var testMessage = "This is a test message";
            await Clients.Caller.SendAsync("Test", testMessage);
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await Task.Run(() => Console.WriteLine("Client disconnected"));
        }
        
        public Task SetSpeed(double speed)
        {
            return _mediator.Send(new SetSpeedRequest() {Speed = speed});
        }
    }
}