using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Shared.RequestReply;

namespace Server.RequestReply
{
    class OpenRequest
    {
        public Type ResponseType { get; set; }
        public TaskCompletionSource<dynamic> CompletionSource { get; set; }
    }
    
    public class ServerRequester : IServerRequester, IServerRequesterSink
    {

        private readonly string _connectionId;
        private readonly IHubContext<ServerHub> _context;
        private readonly Dictionary<Guid, OpenRequest> _openRequests = new();

        public ServerRequester(string connectionId, IHubContext<ServerHub> context)
        {
            _connectionId = connectionId;
            _context = context;
        }
        
            
        public async Task<TResponse> Request<TRequest, TResponse>(ServerRequest<TRequest, TResponse> request)
        {

            var requestGuid = new Guid();
            var message = new RawMessage() { Id = requestGuid };
            TaskCompletionSource<dynamic> completionSource = new();
            _openRequests[requestGuid] = new OpenRequest() { ResponseType = typeof(TResponse), CompletionSource = completionSource};
            
            await _context.Clients.Client(_connectionId).SendAsync("request", message);
            
            return await completionSource.Task;
        }

        public void OnRequestReply(Guid requestId, object message)
        {
            if (!_openRequests.ContainsKey(requestId))
            {
                return;
            }
            
            var openRequest = _openRequests[requestId];

            if (message.GetType() != openRequest.ResponseType)
            {
                return;
            }
            
            openRequest.CompletionSource.SetResult(message);
            _openRequests.Remove(requestId);
        }
    }
}