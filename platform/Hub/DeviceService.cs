using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Hub.Data;
using Hub.Server;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub
{
    public class DeviceService : IDeviceService
    {
        private readonly IApiBroadcaster _broadcaster;
        private readonly IStateRepository _stateRepository;
        private readonly ILogger<DeviceService> _logger;

        public DeviceService(IApiBroadcaster broadcaster, IStateRepository stateRepository, ILogger<DeviceService> logger)
        {
            _stateRepository = stateRepository;
            _broadcaster = broadcaster;
            _logger = logger;
        }
        
        public async Task DeviceConnected(string deviceId)
        {
            _logger.LogInformation("Client connected: {String}", deviceId);

            var lastState = await _stateRepository.GetLastDeviceState(deviceId);

            DeviceState newState;
            if (lastState == null)
            {
                newState = new DeviceState() { DeviceId = deviceId, Connected = true };
            }
            else
            {
                newState = lastState with {Connected = true};
            }

            await _stateRepository.SetDeviceState(newState);
            await BroadcastDeviceChange(newState);
        }

        public async Task DeviceDisconnected(string deviceId)
        {
            _logger.LogInformation("Client disconnected: {DeviceId}", deviceId);
            var lastState = await _stateRepository.GetLastDeviceState(deviceId);

            if (lastState == null)
            {
                _logger.LogWarning("Trying to set disconnected state of unknown device: {DeviceId}", deviceId);
                return;
            }
            
            var newState = lastState with {Connected = false};
                
            await _stateRepository.SetDeviceState(newState);
            await BroadcastDeviceChange(newState);
        }

        public async Task SetDeviceInfo(string deviceId, DeviceInfo deviceInfo)
        {
            
            var lastState = await _stateRepository.GetLastDeviceState(deviceId);

            if (lastState == null)
            {
                _logger.LogWarning("Trying to set state of unknown device: {DeviceId}", deviceId);
                return;
            }
            
            var newState = lastState with {Info = deviceInfo};
                
            await _stateRepository.SetDeviceState(newState);
            await BroadcastDeviceChange(newState);
        }

        public async Task SetStateOfDevice(string deviceId, string state)
        {
            var lastState = await _stateRepository.GetLastDeviceState(deviceId);

            if (lastState == null)
            {
                _logger.LogWarning("Trying to set state of unknown device: {DeviceId}", deviceId);
                return;
            }
            
            var newState = lastState with {State = state, LastUpdate = DateTime.UtcNow};
                
            await _stateRepository.SetDeviceState(newState);
            await BroadcastDeviceChange(newState);
        }

        public Task<IEnumerable<DeviceState>> GetDeviceStates()
        {
            return _stateRepository.GetLastDeviceStates();
        }

        public Task<IEnumerable<DeviceState>> GetDeviceStateHistory(string deviceId, DateTime? start = null, DateTime? end = null, int? intervalSeconds = null, int? count = null)
        {
            return _stateRepository.GetStateHistoryForDevice(deviceId, start, end, intervalSeconds, count);
        }

        private async Task BroadcastDeviceChange(DeviceState changedDevice)
        {
            if (changedDevice.Info == null || (changedDevice.Connected && changedDevice.State == null))
            {
                return;
            }
            
            await _broadcaster.DeviceStateChanged(new List<DeviceState>() { changedDevice });
        }
    }
}