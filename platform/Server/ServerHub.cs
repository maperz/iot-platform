using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Reflection;
using EmpoweredSignalR;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Server.Connection;
using Server.Domain;
using Shared;

namespace Server
{
    public class ServerHub : EmpoweredHub, IApiMethods, IApiListener, IServerMethods
    {
        private readonly ILogger<ServerHub> _logger;
        private readonly IMediator _mediator;
        
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly IUserHubManager _userHubManager;
        
        public ServerHub(ILogger<ServerHub> logger, IMediator mediator, 
            IGatewayConnectionManager connectionManager,
            IUserHubManager userHubManager
            )
        {
            _logger = logger;
            _mediator = mediator;
            _connectionManager = connectionManager;
            _userHubManager = userHubManager;
        }
        
        public override async Task OnConnectedAsync()
        {
            var connectionId = Context.ConnectionId;

            _logger.LogInformation("SignalR Client connected {ClientId}", connectionId);
            await Groups.AddToGroupAsync(connectionId, "clients");

            var user = GetUser();
            if (user != null)
            {
                var hubId = await _userHubManager.GetHubForUser(user.Id);
                if (hubId != null)
                {
                    var hubGroup = $"HUB:{hubId}";
                    await Groups.AddToGroupAsync(connectionId, hubGroup);
                }
                
                var info = await GetConnectionInfoForUser(user);
                await Clients.Caller.SendAsync(nameof(ConnectionInfo), info);
            }
            
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var connectionId = Context.ConnectionId;

            _logger.LogInformation("SignalR Client disconnected {ClientId}", connectionId);

            var hubConnection = _connectionManager.GetConnectionByConnectionId(connectionId);
            if (hubConnection != null && _connectionManager.RemoveConnection(connectionId))
            {
                var hubGroup = hubConnection.GetHubGroupName();
                await Clients.Group(hubGroup).SendAsync(nameof(ConnectionInfo), GetDisconnectedInfo());
            }
            
            await base.OnDisconnectedAsync(exception);
        }
        
        public async Task RegisterAsGateway(string hubId)
        {
            _logger.LogInformation("Gateway registering with HubId: {HubId}, and CId: {ConnectionId} ...", hubId, Context.ConnectionId);
            try
            {
                var connectionId = Context.ConnectionId;
                var ip = Context.Features.Get<IHttpConnectionFeature>().RemoteIpAddress;
                var address = ip?.ToString() ?? "No address info";
                
                _connectionManager.AddConnection(connectionId, address, hubId);
                var hubConnection = _connectionManager.GetConnectionByConnectionId(connectionId);

                await Groups.RemoveFromGroupAsync(connectionId, "clients");
                await Groups.AddToGroupAsync(connectionId, "gateways");
                
                _logger.LogInformation("Gateway successfully registered with HubId: {HubId}, and CId: {ConnectionId}!", hubId,
                    Context.ConnectionId);
                
                if (hubConnection != null)
                {
                    // Update all users waiting for this hub
                    var hubGroup = hubConnection.GetHubGroupName();
                    await Clients.Group(hubGroup).SendAsync(nameof(ConnectionInfo), await hubConnection.GetConnectionInfo());
                }

            }
            catch(Exception e)
            {
                _logger.LogError("Failed to register Gateway with HubId: {HubId}, and CId: {ConnectionId}, {Error}", hubId,
                    Context.ConnectionId, e.Message);
            }
        }
        
        
        [Authorize]
        public async Task<IEnumerable<DeviceState>> GetDeviceList()
        {
            var hubId = await GetHubIdForCurrentUser();
            return await _mediator.Send(new GetDeviceListRequest() {HubId = hubId});
        }

        [Authorize]
        public async Task SendRequest(string deviceId, string name, string payload)
        {
            var hubId = await GetHubIdForCurrentUser();
            await _mediator.Send(new SendHubDeviceRequest()
                {HubId = hubId, DeviceId = deviceId, Name = name, Payload = payload});
        }

        [Authorize]
        public async Task ChangeDeviceName(string deviceId, string name)
        {
            var hubId = await GetHubIdForCurrentUser();
            await _mediator.Send(new SetNameRequest()
                {HubId = hubId, DeviceId = deviceId, Name = name});
        }
        
        
        public Task DeviceStateChanged(IEnumerable<DeviceState> deviceStates)
        {
            // _logger.LogInformation("Sending Device State change to clients");

            var connectionId = Context.ConnectionId;
            var connection = _connectionManager.GetConnectionByConnectionId(connectionId);

            if (connection == null)
            {
                _logger.LogWarning("Trying to send device state change as not registered hub");
                return Task.CompletedTask;
            }

            var hubGroup = connection.GetHubGroupName();
            return Clients.Group(hubGroup).SendAsync(nameof(IApiListener.DeviceStateChanged), deviceStates);
        }

        private async Task<string> GetHubIdForCurrentUser()
        {
            var user = GetUser();
            if (user == null)
            {
                throw new Exception("Cannot get hub id if no user is authenticated");
            }
            
            var hubId = await _userHubManager.GetHubForUser(user.Id);
            if (hubId == null)
            {
                throw new NoConnectionException();
            }

            return hubId;
        }

        public Task<ConnectionInfo> GetConnectionInfo()
        {
            var user = GetUser();
            if (user == null)
            {
                throw new Exception("Cannot get connection info if no user is authenticated");
            }

            return GetConnectionInfoForUser(user);
        }
        
        private async Task<ConnectionInfo> GetConnectionInfoForUser(User user)
        {
            var hubId = await _userHubManager.GetHubForUser(user.Id);
            if (hubId == null) return GetDisconnectedInfo();
            
            var connection = _connectionManager.GetConnectionByHubId(hubId);
            if (connection != null)
            {
                return await connection.GetConnectionInfo();
            }

            return GetDisconnectedInfo();
        }
        
        private User? GetUser()
        {
            var username = Context.User!.Claims.FirstOrDefault(x => x.Type == "name")?.Value;
            var id = Context.User!.Claims.FirstOrDefault(x => x.Type == "user_id")?.Value;

            if (username == null || id == null)
            {
                return null;
            }
            
            return new User() { Name = username, Id = id };
        }
        
        private ConnectionInfo GetDisconnectedInfo()
        {
            return new ()
            {
                IsConnected = false,
                IsProxy = true,
                ProxiedAddress = null,
                HubId = null,
                Version = GetType()
                    .Assembly
                    .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "",
            };
        }
    }
}