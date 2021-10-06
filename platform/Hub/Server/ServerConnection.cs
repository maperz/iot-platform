using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EmpoweredSignalR;
using Hub.Config;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
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
        private readonly string _serverHubAddress;
        
        public ServerConnection(IMediator mediator, ILogger<ServerConnection> logger, IApiBroadcaster apiBroadcaster,
            IDeviceService deviceService,
            IOptions<HubConfig> hubConfigOptions,
            IOptions<ServerConnectionConfig> serverConfigOptions)
        {
            _logger = logger;
            _mediator = mediator;
            _deviceService = deviceService;
            
            _hubId = hubConfigOptions.Value.HubId;
            _serverHubAddress = serverConfigOptions.Value.ServerBaseAddress + "/hub";
            
            _hubConnection = new HubConnectionBuilder().WithUrl(_serverHubAddress)
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
                    _logger.LogInformation("Attempting to reconnect to server. [Address={Address}]",
                        _serverHubAddress);
                }
                else
                {
                    _logger.LogError("Attempting to reconnect to server. [Address={Address}, Error={Error}]",
                        _serverHubAddress, error.Message);
                }
            });
            
            _hubConnection.Reconnected += _ => ConnectionEstablished();
            _hubConnection.Closed += _ => Task.Run(() => _logger.LogInformation("Lost connection to server"));
        }

        public Task<bool> IsConnected()
        {
            return Task.FromResult(_hubConnection.State == HubConnectionState.Connected);
        }
        
        private async Task ConnectionEstablished(CancellationToken cancellationToken = default)
        {
            await _hubConnection.InvokeAsync(nameof(IServerMethods.RegisterAsGateway), _hubId, cancellationToken);
            _logger.LogInformation("Connected successfully to server");

            var states = await _deviceService.GetDeviceStates();
            await DeviceStateChanged(states);
        }
        
        public async Task<bool> Connect(CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("Establishing server connection. [Address={Address}]", _serverHubAddress);
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
                    _logger.LogInformation("Connecting process stopped by cancellation token");
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