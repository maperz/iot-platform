using System.Threading;
using System.Threading.Tasks;
using Shared;

namespace Hub.Server
{
    public interface IServerConnection : IApiListener
    {
        public Task<bool> Connect(CancellationToken cancellationToken = default);

        public Task<bool> IsConnected();
    }
}