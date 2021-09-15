using System.Collections.Generic;
using System.Linq;
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
        private readonly string _hubId;
        private readonly IDeviceService _deviceService;
        private readonly string _serverAddress;


        public ServerConnection(IMediator mediator, ILogger<ServerConnection> logger, IApiBroadcaster apiBroadcaster,
            IDeviceService deviceService,
            AppSettings appSettings)
        {
            _logger = logger;
            _mediator = mediator;
            _hubId = appSettings.HubId;
            _deviceService = deviceService;

            _serverAddress = appSettings.ServerAddress;
            
            _logger.LogInformation("Creating server hub connection with address at {String}", _serverAddress);
            
            _hubConnection = new HubConnectionBuilder().WithUrl(_serverAddress)
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
            
            _hubConnection.Reconnecting += error=> Task.Run(() =>
            {
                if (error == null)
                {
                    _logger.LogInformation("Attempting to reconnect to server at {Address}",
                        _serverAddress);
                }
                else
                {
                    _logger.LogError("Attempting to reconnect to server at {Address} after {Error}",
                        _serverAddress, error.Message);
                }
            });
            
            _hubConnection.Reconnected += _ => ConnectionEstablished();
            _hubConnection.Closed += _ => Task.Run(() => _logger.LogInformation("Lost connection to Server"));
        }

        public Task<bool> IsConnected()
        {
            return Task.FromResult(_hubConnection.State == HubConnectionState.Connected);
        }
        
        private async Task ConnectionEstablished(CancellationToken cancellationToken = default)
        {
            await _hubConnection.InvokeAsync(nameof(IServerMethods.RegisterAsGateway), _hubId, cancellationToken);
            _logger.LogInformation("Connected to Server");

            var states = await _deviceService.GetDeviceStates();
            await DeviceStateChanged(states);
        }
        
        public async Task<bool> Connect(CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Establishing server connection");
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    await _hubConnection.StartAsync(cancellationToken);
                    await ConnectionEstablished(cancellationToken);
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
            if (await IsConnected() && deviceStates.Any())
            { 
                await _hubConnection.InvokeAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
            }
        }
    }
}