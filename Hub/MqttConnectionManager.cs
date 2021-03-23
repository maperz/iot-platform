using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using MQTTnet.Server;

namespace Hub
{
    public class MqttConnectionManager : BackgroundService, IMqttServerClientConnectedHandler, IMqttServerClientDisconnectedHandler
    {
        private readonly IDeviceService _deviceService;
        private readonly IMqttServer _mqttServer;

        public MqttConnectionManager(IDeviceService deviceService, IMqttServer server)
        {
            _mqttServer = server;
            _deviceService = deviceService;
        }
        
        public Task HandleClientConnectedAsync(MqttServerClientConnectedEventArgs args)
        {
            var deviceId = args.ClientId;
            _deviceService.DeviceConnected(deviceId);
            
            return Task.CompletedTask;
        }

        public Task HandleClientDisconnectedAsync(MqttServerClientDisconnectedEventArgs args)
        {
            var deviceId = args.ClientId;
            _deviceService.DeviceDisconnected(deviceId);
            return Task.CompletedTask;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _mqttServer.ClientConnectedHandler = this;
            _mqttServer.ClientDisconnectedHandler = this;
            
            _mqttServer.UseApplicationMessageReceivedHandler(async e =>
            {
                var topic = e.ApplicationMessage.Topic;
                if (topic.EndsWith("/state"))
                {
                    var deviceId = topic.Split("/")[0];
                    var message = Encoding.UTF8.GetString(e.ApplicationMessage.Payload);
                    var state = double.Parse(message);
                    await _deviceService.SetStateOfDevice(deviceId, state);
                }
            });
            
            return Task.CompletedTask;
        }
    }
}