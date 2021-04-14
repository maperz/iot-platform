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
        private readonly ReaderWriterLockSlim _lock = new();
        private readonly Dictionary<string, DeviceState> _deviceStates = new();
        private readonly IApiBroadcaster _broadcaster;
        private readonly ILogger<DeviceService> _logger;

        public DeviceService(IApiBroadcaster broadcaster, ILogger<DeviceService> logger)
        {
            _broadcaster = broadcaster;
            _logger = logger;
        }
        
        public Task DeviceConnected(string deviceId)
        {
            _lock.EnterWriteLock();
            try
            {
                _logger.LogInformation("Client connected: {String}", deviceId);

                if (!_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    deviceState = new DeviceState() {DeviceId = deviceId};
                    _deviceStates.Add(deviceId, deviceState);
                }

                deviceState.Connected = true;
                _broadcaster.DeviceStateChanged(new List<DeviceState>() { deviceState });
            }
            finally
            {
                _lock.ExitWriteLock();
            }

            return Task.CompletedTask;
        }

        public Task DeviceDisconnected(string deviceId)
        {
            _lock.EnterWriteLock();
            try
            {
                if (_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    _logger.LogInformation("Client disconnected: {String}", deviceId);

                    deviceState.Connected = false;
                    _broadcaster.DeviceStateChanged(new List<DeviceState>() { deviceState });
                }
            }
            finally
            {
                _lock.ExitWriteLock();
            }
         
            return Task.CompletedTask;
        }

        public Task SetStateOfDevice(string deviceId, double state)
        {
            _lock.EnterWriteLock();
            try
            {
                if (!_deviceStates.TryGetValue(deviceId, out var deviceState))
                {
                    _logger.LogWarning("Trying to set state of unknown device not found: {String}", deviceId);
                    return Task.CompletedTask;
                    ;
                } 
                
                if (deviceState.Speed == null || Math.Abs((double) (deviceState.Speed - state)) > double.Epsilon)
                {
                    deviceState.Speed = state;
                    _broadcaster.DeviceStateChanged(new List<DeviceState>() { deviceState });
                }
            }
            finally
            {
                _lock.ExitWriteLock();
            }
         
            return Task.CompletedTask;
        }

        public Task<IEnumerable<DeviceState>> GetDeviceStates()
        {
            _lock.EnterReadLock();
            try
            {
                return Task.FromResult(_deviceStates.Values.ToList() as IEnumerable<DeviceState>);
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }
    }
}