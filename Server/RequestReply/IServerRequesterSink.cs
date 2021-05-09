using System;

namespace Server.RequestReply
{
    public interface IServerRequesterSink
    {
        void OnRequestReply(Guid requestId, object message);
    }
}