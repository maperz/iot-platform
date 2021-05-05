using System.Collections.Generic;
using System.Threading.Tasks;
using Shared;

namespace Hub
{
    public interface IDeviceService
    {
        public Task DeviceConnected(string deviceId);
        public Task DeviceDisconnected(string deviceId);

        public Task SetDeviceInfo(string deviceId, DeviceInfo deviceInfo);
        
        public Task SetStateOfDevice(string deviceId, double state);

        public Task<IEnumerable<DeviceState>> GetDeviceStates();
    }
}