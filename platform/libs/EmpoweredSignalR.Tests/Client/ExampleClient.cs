using System;
using System.Threading;
using System.Threading.Tasks;
using EmpoweredSignalR.Tests.Hub;
using Microsoft.AspNetCore.SignalR.Client;

namespace EmpoweredSignalR.Tests.Client
{
    public class ExampleClient : IAsyncDisposable
    {
        private readonly HubConnection _hubConnection;
        private readonly Receiver _receiver;
        private CancellationTokenSource _cancellationTokenSource;

        public ExampleClient(Receiver receiver, int port, string serverAddress = "http://localhost")
        {
            
            _hubConnection = new HubConnectionBuilder().WithUrl(serverAddress + $":{port}/hub")
                .Build();
            _receiver = receiver;
        }

        public Task Start()
        {
            if (_cancellationTokenSource != null)
            {
                throw new Exception("Already started Example Client");
            }

            _cancellationTokenSource = new CancellationTokenSource();

            var waitHandle = new AutoResetEvent(false);
            
            new Thread(async () =>
            {
                await RunInternal(waitHandle, _cancellationTokenSource.Token);
            }).Start();

            waitHandle.WaitOne();
            return Task.CompletedTask;
        }

        private async Task RunInternal(EventWaitHandle waitHandle, CancellationToken token)
        {
            await _hubConnection.StartAsync(token);
            _hubConnection.AddBidirectionalReceiver(_receiver);

            waitHandle.Set();
            
            while (!token.IsCancellationRequested)
            {
                Thread.Sleep(2);
            }
            
            
            await _hubConnection.StopAsync(token);
        }

        private Task Stop()
        {
            _cancellationTokenSource?.Cancel();
            return Task.CompletedTask;
        }

        public async Task MakePingRequest()
        {
            await _hubConnection.InvokeAsync(nameof(ExampleHub.MakePingRequest));
        }
        
        public async Task<string> MakeToUpperRequest(string text)
        {
            return await _hubConnection.InvokeAsync<string>(nameof(ExampleHub.MakeToUpperRequest), text);
        }

        public async ValueTask DisposeAsync()
        {
            if (_hubConnection.State == HubConnectionState.Connected)
            {
                await Stop();
            }
        }
    }
}