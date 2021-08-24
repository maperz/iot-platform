using System.Collections.Generic;
using System.Threading.Tasks;
using Shared;

namespace Hub.Data
{
    public interface IStateRepository
    {
        public Task SetDeviceState(DeviceState state);
        
        public Task<DeviceState?> GetLastDeviceState(string deviceId);
        
        public Task<IEnumerable<DeviceState>> GetLastDeviceStates();
    }
}