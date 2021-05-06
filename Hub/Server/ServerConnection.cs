using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
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
                .WithAutomaticReconnect(new[] { TimeSpan.Zero, TimeSpan.Zero, TimeSpan.FromSeconds(1) })
                .Build();


            apiBroadcaster.ConnectListener(this);
            
            RegisterListeners();
        }

        private void RegisterListeners()
        {
            _hubConnection.On<double>(
                nameof(IApiMethods.SetSpeed), 
                (speed) => _mediator.Send(new SetSpeedRequest() { Speed = speed }));
            
            _hubConnection.On<string, string>(
                nameof(IApiMethods.ChangeDeviceName), 
                (deviceId, name) => _mediator.Send(new SetNameRequest() { DeviceId = deviceId, Name = name}));
        }

        public Task<bool> IsConnected()
        {
            return Task.FromResult(_hubConnection.State == HubConnectionState.Connected);
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

        public async Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            if (await IsConnected())
            { 
                await _hubConnection.InvokeAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
            }
        }
    }
}