using System.Threading;
using Makaretu.Dns;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace Hub
{
    public class LocalServiceDiscovery : BackgroundService
    {

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var serviceDiscovery = new ServiceDiscovery();
            serviceDiscovery.Advertise(new ServiceProfile("IotHub", "_iothub._tcp", 5000));
            serviceDiscovery.Advertise(new ServiceProfile("IotMqtt", "_iotmqtt._tcp", 1883));

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(1000000, stoppingToken);
            }
        }
    }
}