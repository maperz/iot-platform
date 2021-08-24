using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Shared;

namespace Hub.Data
{
    public class StateRepository : IStateRepository
    {
        private readonly SemaphoreSlim _lock = new (1);
        private readonly Dictionary<string, DeviceState> _deviceStates = new();
        
        public async Task SetDeviceState(DeviceState state)
        {
            await _lock.WaitAsync();
            try
            {
                _deviceStates[state.DeviceId] = state;
            }
            finally
            {
                _lock.Release();
            }
        }

        public async Task<DeviceState?> GetLastDeviceState(string deviceId)
        {
            await _lock.WaitAsync();
            try
            {
                return _deviceStates.GetValueOrDefault(deviceId);
            }
            finally
            {
                _lock.Release();
            }        
        }

        public async Task<IEnumerable<DeviceState>> GetLastDeviceStates()
        {
            await _lock.WaitAsync();
            try
            {
                return _deviceStates.Values.Where(x => x.Info != null);
            }
            finally
            {
                _lock.Release();
            }
        }
    }
}