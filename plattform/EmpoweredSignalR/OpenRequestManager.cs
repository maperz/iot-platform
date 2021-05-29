using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EmpoweredSignalR
{
    class OpenRequest
    {
        #nullable disable
        public Guid Id { get; init; }
        public string ConnectionId { get; init; }
        public Type ResponseType { get; init; }
        public TaskCompletionSource<dynamic> CompletionSource { get; init; }
        
        public CancellationTokenSource CancellationSource { get; init; }
        #nullable enable
    }
    
    public class OpenRequestManager 
    {
        private readonly Dictionary<Guid, OpenRequest> _openRequests = new();
        private readonly Dictionary<string, OpenRequest> _connectionRequestMap = new();

        private readonly SemaphoreSlim _lock = new(1);
        private readonly TimeSpan _defaultTimeOut = TimeSpan.FromSeconds(5);
        private static OpenRequestManager? _instance;
        
        public static OpenRequestManager Instance {  
            get { return _instance ??= new OpenRequestManager(); }  
        }  
        
        public async Task<TResponse> CreateOpenRequest<TResponse>(string connectionId, BidirectionalMessage request, TimeSpan? timeOut = null)
        {
            TaskCompletionSource<dynamic> completionSource = new();
            var cts = new CancellationTokenSource(timeOut.GetValueOrDefault(_defaultTimeOut));
            cts.Token.Register(() => OnTimeOut(request.Id));
            
            // ReSharper disable once MethodSupportsCancellation
            await _lock.WaitAsync();
            try
            {
               var openRequest = new OpenRequest()
               {
                   Id = request.Id,
                   ConnectionId =  connectionId,
                   ResponseType = typeof(TResponse), 
                   CompletionSource = completionSource,
                   CancellationSource = cts
               };
               
               AddToRequestMap(request.Id, openRequest);
            }
            finally
            {
                _lock.Release();
            }

            return await completionSource.Task;
        }
        
        public void OnRequestReply(BidirectionalMessage message)
        {
            var requestId = message.Id;
            if (message.Exception != null)
            {
                OnFailure(requestId, message.Exception);
            }
            else
            {
                OnSuccess(requestId, message.Payload);
            }
        }

        public void OnClientDisconnect(string connectionId)
        {
            if (_connectionRequestMap.TryGetValue(connectionId, out var request))
            {
                OnFailure(request.Id, new Exception("Client disconnected"));
            }
        }

        private void AddToRequestMap(Guid id, OpenRequest openRequest)
        {
            _openRequests[id] = openRequest;
            _connectionRequestMap[openRequest.ConnectionId] = openRequest;
        }

        private void RemoveFromRequestMap(Guid id)
        {
            if (!_openRequests.TryGetValue(id, out var request)) return;
            
            _openRequests.Remove(id);
            _connectionRequestMap.Remove(request.ConnectionId);
        }
        
        private void OnTimeOut(Guid requestId)
        {
           OnFailure(requestId, new TimeoutException());
        }

        private void OnSuccess(Guid requestId, string payload)
        {
            _lock.Wait();
            try
            {
                if (!_openRequests.ContainsKey(requestId))
                {
                    return;
                }

                var openRequest = _openRequests[requestId];
                HandleRequestReply(openRequest, payload);
            
                RemoveFromRequestMap(requestId);
            }
            finally
            {
                _lock.Release();
            }
        }
        
        private void OnFailure(Guid requestId, Exception exception)
        {
            _lock.Wait();
            try 
            {
                if (!_openRequests.ContainsKey(requestId))
                {
                    return;
                }

                var openRequest = _openRequests[requestId];
                HandleRequestReply(openRequest, null, exception);
                RemoveFromRequestMap(requestId);
            }
            finally
            {
                _lock.Release();
            }
        }

        private void HandleRequestReply(OpenRequest openRequest, string? message, Exception? exception = null)
        {
            openRequest.CancellationSource.Dispose();

            if (exception != null)
            {
                openRequest.CompletionSource.SetException(exception);
                return;
            }
            
            if (!string.IsNullOrEmpty(message))
            {
                var parsedObject = JsonSerializer.Deserialize(message, openRequest.ResponseType);
                openRequest.CompletionSource.SetResult(parsedObject);
            }
            else
            {
                openRequest.CompletionSource.SetResult(null);
            }
        }
    }
}