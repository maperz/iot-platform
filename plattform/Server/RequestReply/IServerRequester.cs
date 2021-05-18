using System;
using System.Threading.Tasks;
using Shared.RequestReply;

namespace Server.RequestReply
{
    public interface IServerRequester
    {
        Task<TResponse> Request<TResponse>(ServerRequest<TResponse> request, TimeSpan? timeOut = null);
    }
}