using System.Threading;
using System.Threading.Tasks;

namespace Hub.Server
{
    public interface IServerConnection
    {
        Task<bool> Connect(CancellationToken cancellationToken = default);
    }
}