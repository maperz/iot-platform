using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MQTTnet.Server;

namespace Hub
{
    public class MqttConnectionManager : BackgroundService, IMqttServerClientConnectedHandler, IMqttServerClientDisconnectedHandler
    {
        private readonly IDeviceService _deviceService;
        private readonly IMqttServer _mqttServer;
        private readonly ILogger<MqttConnectionManager> _logger;

        public MqttConnectionManager(IDeviceService deviceService, IMqttServer server, ILogger<MqttConnectionManager> logger)
        {
            _mqttServer = server;
            _deviceService = deviceService;
            _logger = logger;
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
                var deviceId = topic.Split("/")[0];
                var message = Encoding.UTF8.GetString(e.ApplicationMessage.Payload);

                await OnDeviceMessageReceived(deviceId, topic, message);
            });
            
            return Task.CompletedTask;
        }

        private async Task OnDeviceMessageReceived(String deviceId, String topic, String message)
        {
            if (topic.EndsWith("/state"))
            {
                var state = double.Parse(message);
                await _deviceService.SetStateOfDevice(deviceId, state);
            }
                
            if (topic.EndsWith("/device"))
            {
                _logger.LogInformation("{String}: Message: '{String}'", deviceId, message);
            }
        } 
    }
}