using System.Collections.Generic;
using System.Threading.Tasks;

namespace Shared
{
    public interface IApiListener
    {
        Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates);
    }
}