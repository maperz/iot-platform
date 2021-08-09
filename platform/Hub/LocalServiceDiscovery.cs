using System;
using System.Threading;
using Makaretu.Dns;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Hub
{
    public class LocalServiceDiscovery : BackgroundService
    {
        
        private static readonly ServiceProfile HubService = new ("IotHub", "_iothub._tcp", 5000);
        private static readonly ServiceProfile MqttService = new ("IotMqtt", "_iotmqtt._tcp", 1883);
        
        private readonly TimeSpan _announceInterval = TimeSpan.FromMinutes(5);
        private readonly ILogger<LocalServiceDiscovery> _logger;

        public LocalServiceDiscovery(ILogger<LocalServiceDiscovery> logger)
        {
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                await AdvertiseServices(stoppingToken);
            }
        }

        private async Task AdvertiseServices(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Advertising services for Hub and Mqtt");

            using var serviceDiscovery = new ServiceDiscovery();
            
            serviceDiscovery.Advertise(HubService);
            serviceDiscovery.Advertise(MqttService);

            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("Announcing services for Hub and Mqtt");
                serviceDiscovery.Announce(HubService);
                serviceDiscovery.Announce(MqttService);
                await Task.Delay(_announceInterval, stoppingToken);
            }
        }
    }
}