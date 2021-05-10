using System;
using Shared.RequestReply;

namespace Server.RequestReply
{
    public interface IServerRequesterSink
    {
        public void OnRequestReply(RawMessage rawMessage);
    }
}