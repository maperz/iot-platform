using System.Threading.Tasks;
using Shared.RequestReply;

namespace Server.RequestReply
{
    public interface IServerRequester
    {
        Task<TResponse> Request<TRequest, TResponse>(ServerRequest<TRequest, TResponse> request);
    }
}