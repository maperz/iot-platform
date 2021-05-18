using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Shared;
using Shared.RequestReply;

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
            _hubConnection.On<RawMessage>(
                "request",
                async (msg) =>
                {
                    try
                    {
                        _logger.LogInformation("Request received");
                        if (msg.PayloadType == nameof(DeviceListRequest))
                        {
                            _logger.LogInformation("GetDeviceListRequest request received");
                            var deviceList = await _mediator.Send(new GetDeviceListRequest());
                            var payload = JsonSerializer.Serialize(deviceList);

                            await _hubConnection.SendAsync(nameof(IServerMethods.Reply),
                                new RawMessage()
                                {
                                    Id = msg.Id, Payload = payload, PayloadType = deviceList.GetType().Name
                                });
                        }
                    }
                    catch (Exception err)
                    {
                        // ignored
                        _logger.LogError("Request error occured {Error}", err);
                    }
                });
            
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
                    
                    await _hubConnection.InvokeAsync(nameof(IServerMethods.RegisterAsGateway), cancellationToken);
                    
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