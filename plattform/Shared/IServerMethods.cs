using System.Threading.Tasks;

namespace Shared
{
    public interface IServerMethods
    {
        public Task RegisterAsGateway(string id);
    }
}