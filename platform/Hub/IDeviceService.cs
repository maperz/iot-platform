using System;
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
        
        public Task SetStateOfDevice(string deviceId, string state);

        public Task<IEnumerable<DeviceState>> GetDeviceStates();
        
        public Task<IEnumerable<DeviceState>> GetDeviceStateHistory(string deviceId, DateTime? start = null, DateTime? end = null, int? intervalSeconds = null);

    }
}