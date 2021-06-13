using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Server.Connection;

namespace Server.Domain
{
    public class SendHubDeviceRequestHandler : AsyncRequestHandler<SendHubDeviceRequest>
    {
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly ILogger<SendHubDeviceRequestHandler> _logger;

        public SendHubDeviceRequestHandler(IGatewayConnectionManager connectionManager, ILogger<SendHubDeviceRequestHandler> logger)
        {
            _connectionManager = connectionManager;
            _logger = logger;
        }
        
        protected override async Task Handle(SendHubDeviceRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Sending request via {Hub} to: {DeviceId}, Name = {Request}", request.HubId, request.DeviceId, request.Name);

            var connection = _connectionManager.GetConnection(request.HubId);

            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            await connection.SendRequest(request.DeviceId, request.Name, request.Payload);
        }
    }
}