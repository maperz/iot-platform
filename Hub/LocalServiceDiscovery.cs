using Makaretu.Dns;
using System.Threading.Tasks;

namespace Hub
{
    public class LocalServiceDiscovery
    {
        public Task Advertise(string name, string serviceName, ushort port)
        {
            var service = new ServiceProfile(name, serviceName, port);
            
            var sd = new ServiceDiscovery();
            sd.Advertise(service);

            return Task.CompletedTask;
        }
    }
}