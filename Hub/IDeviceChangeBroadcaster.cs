using System.Collections.Generic;
using System.Threading.Tasks;
using Shared;

namespace Hub
{
    public interface IDeviceChangeBroadcaster
    {
        Task BroadcastDeviceStatesChange(IEnumerable<DeviceState> deviceStates);
    }
}