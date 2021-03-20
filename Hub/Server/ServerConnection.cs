using System;
using System.Threading;
using System.Threading.Tasks;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Hub.Server
{
    public class ServerConnection : BackgroundService, IServerConnection
    {
        private readonly string ServerHubAddress = "http://localhost:4000/hub";
        private readonly HubConnection _hubConnection;
        private readonly ILogger<ServerConnection> _logger;
        
        public ServerConnection(IMediator mediator, ILogger<ServerConnection> logger)
        {
            _logger = logger;
            
            _logger.LogInformation("Creating server hub connection with address at {String}", ServerHubAddress);
            _hubConnection = new HubConnectionBuilder().WithUrl(ServerHubAddress)
                .WithAutomaticReconnect(new[] { TimeSpan.Zero, TimeSpan.Zero, TimeSpan.FromSeconds(1) })
                .Build();
            
            _hubConnection.On<double>("SetSpeed", (speed) => mediator.Send(new SetSpeedRequest() {Speed = speed}));
        }

        public async Task<bool> Connect(CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Establishing server connection");
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    await _hubConnection.StartAsync(cancellationToken);
                    _logger.LogInformation("Connected to Server");
                    return true;
                }
                catch when (cancellationToken.IsCancellationRequested)
                {
                    _logger.LogInformation("Connecting stopped by cancellation token");
                    return false;
                }
                catch
                {
                    await Task.Delay(1000, cancellationToken);
                }
            }

            return false;
        }
        
        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {            
            return Connect(stoppingToken);
        }
    }
}