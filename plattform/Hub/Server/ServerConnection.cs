using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EmpoweredSignalR;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub.Server
{
    public class ServerConnection : BackgroundService, IServerConnection
    {
        private readonly HubConnection _hubConnection;
        private readonly ILogger<ServerConnection> _logger;
        private readonly IMediator _mediator;

        public ServerConnection(IMediator mediator, ILogger<ServerConnection> logger, IApiBroadcaster apiBroadcaster, AppSettings appSettings)
        {
            _logger = logger;
            _mediator = mediator;

            var serverAddress = appSettings.ServerAddress;
            
            _logger.LogInformation("Creating server hub connection with address at {String}", serverAddress);
            
            _hubConnection = new HubConnectionBuilder().WithUrl(serverAddress)
                .WithAutomaticReconnect(new ServerRetryPolicy())
                .Build();

            apiBroadcaster.ConnectListener(this);
            
            RegisterListeners();
        }

        private void RegisterListeners()
        {
            _hubConnection.AddBidirectionalReceiver(new ServerReceiver(_mediator, _logger));
            
            _hubConnection.On<string, string, string>(
                nameof(IApiMethods.SendRequest), 
                async (deviceId, name, payload) =>
                {
                    await _mediator.Send(new SendDeviceRequest() { DeviceId = deviceId, Name = name, Payload = payload});
                });
            
            _hubConnection.On<string, string>(
                nameof(IApiMethods.ChangeDeviceName),
                async (deviceId, name) =>
                {
                    await _mediator.Send(new SetNameRequest() {DeviceId = deviceId, Name = name});
                });
            
            _hubConnection.Reconnecting += (_ => Task.Run(() => _logger.LogInformation("Attempting to reconnect to Server")));
            _hubConnection.Reconnected += (_ => OnConnectionEstablished());
            _hubConnection.Closed += (_ => Task.Run(() => _logger.LogInformation("Lost connection to Server")));
        }

        public Task<bool> IsConnected()
        {
            return Task.FromResult(_hubConnection.State == HubConnectionState.Connected);
        }

        private async Task OnConnectionEstablished(CancellationToken cancellationToken = default)
        {
            await _hubConnection.InvokeAsync(nameof(IServerMethods.RegisterAsGateway), cancellationToken);
            _logger.LogInformation("Connected to Server");
        }
        
        public async Task<bool> Connect(CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Establishing server connection");
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    await _hubConnection.StartAsync(cancellationToken);
                    await OnConnectionEstablished(cancellationToken);
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

        public async Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            if (await IsConnected())
            { 
                await _hubConnection.InvokeAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
            }
        }
    }
}