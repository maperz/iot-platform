using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using MQTTnet.Server;

namespace Hub
{
    public class GatewayHub : Microsoft.AspNetCore.SignalR.Hub
    {
        private readonly IMqttServer _mqttServer;
        public GatewayHub(IMqttServer mqttServer)
        {
            _mqttServer = mqttServer;
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
        
        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);
        }
        
        public async Task SetSpeed(double speed)
        {
            Console.WriteLine("Received Speed value: " + speed);
            await Clients.Caller.SendAsync("Test", "Setting speed to: " + speed);

            speed = Math.Abs(speed);
            speed = Math.Max(0.0, Math.Min(1.0, speed));

            await _mqttServer.PublishAsync("speed", speed.ToString());
        }
    }
}