using System.Collections.Generic;
using System.Threading.Tasks;

namespace Shared
{
    public interface IApiMethods
    {
        public Task<IEnumerable<DeviceState>> GetDeviceList();
        
        public Task SetSpeed(string deviceId, double speed);
        
        public Task ChangeDeviceName(string deviceId, string name);
    }
}