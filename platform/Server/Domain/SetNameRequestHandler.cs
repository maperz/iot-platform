using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Server.Connection;

namespace Server.Domain
{
    public class SetNameRequestHandler : AsyncRequestHandler<SetNameRequest>
    {
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly ILogger<SetNameRequestHandler> _logger;

        public SetNameRequestHandler(IGatewayConnectionManager connectionManager, ILogger<SetNameRequestHandler> logger)
        {
            _connectionManager = connectionManager;
            _logger = logger;
        }
        
        protected override async Task Handle(SetNameRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Changing name requested for client via {Hub}: {DeviceId} to name: '{Name}' ",
                request.HubId, request.DeviceId, request.Name);
            
            var connection = _connectionManager.GetConnectionByHubId(request.HubId);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            await connection.ChangeDeviceName(request.DeviceId, request.Name);
        }
    }
}