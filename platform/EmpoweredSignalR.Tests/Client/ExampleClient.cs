using System;
using System.Threading.Tasks;
using EmpoweredSignalR.Tests.Hub;
using Microsoft.AspNetCore.SignalR.Client;

namespace EmpoweredSignalR.Tests.Client
{
    public class ExampleClient : IAsyncDisposable
    {
        private readonly HubConnection _hubConnection;
        private readonly Receiver _receiver;
        
        public ExampleClient(Receiver receiver, string serverAddress = "http://localhost:5000/hub")
        {
            _hubConnection = new HubConnectionBuilder().WithUrl(serverAddress)
                .Build();
            _receiver = receiver;
        }

        public async Task Start()
        {
            await _hubConnection.StartAsync();
            _hubConnection.AddBidirectionalReceiver(_receiver);
        }

        public async Task Stop()
        {
            await _hubConnection.StopAsync();
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