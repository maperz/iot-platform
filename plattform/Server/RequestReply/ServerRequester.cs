using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Shared.RequestReply;

namespace Server.RequestReply
{
    class OpenRequest
    {
        public Type ResponseType { get; set; }
        public TaskCompletionSource<dynamic> CompletionSource { get; set; }
        
        public CancellationTokenSource CancellationSource { get; set; }

    }
    
    public class ServerRequester : IServerRequester, IServerRequesterSink
    {

        private readonly string _connectionId;
        private readonly IHubContext<ServerHub> _context;
        private readonly Dictionary<Guid, OpenRequest> _openRequests = new();
        private readonly SemaphoreSlim _lock = new(1);

        private readonly TimeSpan _defaultTimeOut = TimeSpan.FromSeconds(5);
        
        public ServerRequester(string connectionId, IHubContext<ServerHub> context)
        {
            _connectionId = connectionId;
            _context = context;
        }
        
        public async Task<TResponse> Request<TResponse>(ServerRequest<TResponse> request, TimeSpan? timeOut = null)
        {
            var requestGuid = Guid.NewGuid();

            var payload = JsonSerializer.Serialize(request);
            var message = new RawMessage { Id = requestGuid, Payload = payload, PayloadType = request.GetType().Name };
            TaskCompletionSource<dynamic> completionSource = new();
            var cts = new CancellationTokenSource(timeOut.GetValueOrDefault(_defaultTimeOut));
            cts.Token.Register(() => OnTimeOut(requestGuid));
            
            await _lock.WaitAsync();
            try
            {
                _openRequests[requestGuid] = new OpenRequest()
                {
                    ResponseType = typeof(TResponse), 
                    CompletionSource = completionSource,
                    CancellationSource = cts
                };
            }
            finally
            {
                _lock.Release();
            }
            
            await _context.Clients.Client(_connectionId).SendAsync("request", message);
            
            return await completionSource.Task;
        }
        
        
        public void OnRequestReply(RawMessage rawMessage)
        {
            var requestId = rawMessage.Id;
            
            _lock.Wait();
            try
            {
                if (!_openRequests.ContainsKey(requestId))
                {
                    return;
                }

                var openRequest = _openRequests[requestId];
                HandleRequestReply(openRequest, rawMessage.Payload, null);
            
                _openRequests.Remove(requestId);
            }
            finally
            {
                _lock.Release();
            }
        }
        
        private void OnTimeOut(Guid requestId)
        {
            _lock.Wait();
            try 
            {
                if (!_openRequests.ContainsKey(requestId))
                {
                    return;
                }

                var openRequest = _openRequests[requestId];
                HandleRequestReply(openRequest, null, new TimeoutException());
                _openRequests.Remove(requestId);
            }
            finally
            {
                _lock.Release();
            }
        }

        private void HandleRequestReply(OpenRequest openRequest, string message, Exception exception = null)
        {
            openRequest.CancellationSource.Dispose();

            if (exception != null)
            {
                openRequest.CompletionSource.SetException(exception);
                return;
            }
            
            if (!string.IsNullOrEmpty(message))
            {
                var parsedObject = JsonSerializer.Deserialize(message, openRequest.ResponseType, null);
                openRequest.CompletionSource.SetResult(parsedObject);
            }
            else
            {
                openRequest.CompletionSource.SetResult(null);
            }

        }
    }
}