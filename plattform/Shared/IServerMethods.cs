using System.Threading.Tasks;
using Shared.RequestReply;

namespace Shared
{
    public interface IServerMethods
    {
        public Task RegisterAsGateway();
        
        public Task Reply(RawMessage rawMessage);
    }
}