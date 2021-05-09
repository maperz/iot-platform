using Server.RequestReply;
using Shared;

namespace Server
{
    public interface IGatewayConnection : IApiMethods
    {
        IServerRequesterSink RequestSink { get; }
    }
}