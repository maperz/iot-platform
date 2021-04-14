using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Shared
{
    public class ApiBroadcaster : IApiBroadcaster
    {
        private readonly List<IApiListener> _listeners = new(); 
        
        public async Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            await Task.WhenAll(_listeners.Select(l => l.DeviceStateChanged(deviceStates)));
        }
        
        public Task ConnectListener(IApiListener apiListener)
        {
            _listeners.Add(apiListener);
            return OnListenerConnected(apiListener);
        }

        public Task DisconnectListener(IApiListener apiListener)
        {
            _listeners.Remove(apiListener);
            return OnListenerDisconnected(apiListener);
        }
        
        protected Task OnListenerConnected(IApiListener apiListener) 
        { 
            return Task.CompletedTask;
        }
        
        protected Task OnListenerDisconnected(IApiListener apiListener) 
        { 
            return Task.CompletedTask;
        }
    }
}