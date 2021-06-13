using System.Threading.Tasks;

namespace Shared
{
    public interface IApiBroadcaster : IApiListener
    {
        public Task ConnectListener(IApiListener apiListener);

        public Task DisconnectListener(IApiListener apiListener);
    }
}