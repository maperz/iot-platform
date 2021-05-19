using System.Collections.Generic;
using System.Threading.Tasks;

namespace Shared
{
    public interface IApiMethods
    {
        public Task<IEnumerable<DeviceState>> GetDeviceList();
        
        public Task SendRequest(string deviceId, string name, string payload);

        public Task ChangeDeviceName(string deviceId, string name);

        public Task<ConnectionInfo> GetConnectionInfo();
    }
}