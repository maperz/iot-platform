using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Shared
{
    public class ApiBroadcaster : IApiBroadcaster
    {
        private readonly List<IApiListener> _listeners = new(); 
        private readonly ReaderWriterLockSlim _lock = new();

        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            _lock.EnterReadLock();
            try
            {
                foreach (var listener in _listeners)
                {
                    _ = listener.DeviceStateChanged(deviceStates);
                }

                return Task.CompletedTask;
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }
        
        public Task ConnectListener(IApiListener apiListener)
        {
            _lock.EnterWriteLock();
            try
            {
                _listeners.Add(apiListener);
            }
            finally
            {
                _lock.ExitWriteLock();
            }
            
            return Task.CompletedTask;
        }

        public Task DisconnectListener(IApiListener apiListener)
        {
            _lock.EnterWriteLock();
            try
            {
                _listeners.Remove(apiListener);
            }
            finally
            {
                _lock.ExitWriteLock();
            }
            
            return Task.CompletedTask;
        }
    }
}