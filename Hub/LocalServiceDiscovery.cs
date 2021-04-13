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
        private readonly TimeSpan _announceInterval = TimeSpan.FromMinutes(5);
        private readonly ILogger<LocalServiceDiscovery> _logger;

        public LocalServiceDiscovery(ILogger<LocalServiceDiscovery> logger)
        {
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var serviceDiscovery = new ServiceDiscovery();
            var hubProfile = new ServiceProfile("IotHub", "_iothub._tcp", 5000);
            var mqttProfile = new ServiceProfile("IotMqtt", "_iotmqtt._tcp", 1883);
            
            serviceDiscovery.Advertise(hubProfile);
            serviceDiscovery.Advertise(mqttProfile);
            _logger.LogInformation("Advertising services setup completed");

            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("Announcing services ...");
                serviceDiscovery.Announce(hubProfile);
                serviceDiscovery.Announce(mqttProfile);
                await Task.Delay(_announceInterval, stoppingToken);
            }
        }
    }
}