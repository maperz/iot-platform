using System.Threading.Tasks;

namespace Shared
{
    public interface IApiMethods
    {
        public Task SetSpeed(string deviceId, double speed);
        
        public Task ChangeDeviceName(string deviceId, string name);
    }
}