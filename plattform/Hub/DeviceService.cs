using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub
{
    public class DeviceService : IDeviceService
    {
        private readonly SemaphoreSlim _lock = new (1);
        private readonly Dictionary<string, DeviceState> _deviceStates = new();
        private readonly IApiBroadcaster _broadcaster;
        private readonly ILogger<DeviceService> _logger;

        public DeviceService(IApiBroadcaster broadcaster, ILogger<DeviceService> logger)
        {
            _broadcaster = broadcaster;
            _logger = logger;
        }
        
        public async Task DeviceConnected(string deviceId)
        {
            await _lock.WaitAsync();
            try
            {
                _logger.LogInformation("Client connected: {String}", deviceId);

                if (!_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    deviceState = new DeviceState() {DeviceId = deviceId};
                    _deviceStates.Add(deviceId, deviceState);
                }

                deviceState.Connected = true;
                await BroadcastDeviceChange(deviceState);
            }
            finally
            {
                _lock.Release();
            }
        }

        public async Task DeviceDisconnected(string deviceId)
        {
            await _lock.WaitAsync();
            try
            {
                if (_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    _logger.LogInformation("Client disconnected: {DeviceId}", deviceId);

                    deviceState.Connected = false;
                    await BroadcastDeviceChange(deviceState);
                }
            }
            finally
            {
                _lock.Release();
            }
        }

        public async Task SetDeviceInfo(string deviceId, DeviceInfo deviceInfo)
        {
            await _lock.WaitAsync();
            try
            {
                if (!_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    _logger.LogWarning("Trying to set state of unknown device not found: {DeviceId}", deviceId);
                    return;
                }

                deviceState.Info = deviceInfo;
                await BroadcastDeviceChange(deviceState);
            }
            finally
            {
                _lock.Release();
            }
        }

        public async Task SetStateOfDevice(string deviceId, string state)
        {
            await _lock.WaitAsync();
            try
            {
                if (!_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    _logger.LogWarning("Trying to set state of unknown device not found: {DeviceId}", deviceId);
                    return;
                }

                deviceState.State = state;
                deviceState.LastUpdate = DateTime.UtcNow;
                await BroadcastDeviceChange(deviceState);
            }
            finally
            {
                _lock.Release();
            }
        }

        public async Task<IEnumerable<DeviceState>> GetDeviceStates()
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

        private Task BroadcastDeviceChange(DeviceState changedDevice)
        {
            return changedDevice.Info == null ? Task.CompletedTask : _broadcaster.DeviceStateChanged(new List<DeviceState>() { changedDevice });
        }
    }
}