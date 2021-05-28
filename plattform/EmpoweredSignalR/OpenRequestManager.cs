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
        public Type ResponseType { get; set; }
        public TaskCompletionSource<dynamic> CompletionSource { get; set; }
        
        public CancellationTokenSource CancellationSource { get; set; }
        #nullable enable
    }
    
    public class OpenRequestManager 
    {
        private readonly Dictionary<Guid, OpenRequest> _openRequests = new();
        private readonly SemaphoreSlim _lock = new(1);
        private readonly TimeSpan _defaultTimeOut = TimeSpan.FromSeconds(5);
        private static OpenRequestManager? _instance;
        
        public static OpenRequestManager Instance {  
            get {  
                if (_instance == null) {  
                    _instance = new OpenRequestManager();  
                }  
                return _instance;  
            }  
        }  
        
        public async Task<TResponse> CreateOpenRequest<TResponse>(BidirectionalMessage request, TimeSpan? timeOut = null)
        {
            TaskCompletionSource<dynamic> completionSource = new();
            var cts = new CancellationTokenSource(timeOut.GetValueOrDefault(_defaultTimeOut));
            cts.Token.Register(() => OnTimeOut(request.Id));
            
            await _lock.WaitAsync();
            try
            {
                _openRequests[request.Id] = new OpenRequest()
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

            return await completionSource.Task;
        }
        
        public void OnRequestReply(BidirectionalMessage bidirectionalMessage)
        {
            var requestId = bidirectionalMessage.Id;
            
            _lock.Wait();
            try
            {
                if (!_openRequests.ContainsKey(requestId))
                {
                    return;
                }

                var openRequest = _openRequests[requestId];
                HandleRequestReply(openRequest, bidirectionalMessage.Payload);
            
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