using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Server.Connection;
using Shared;

namespace Server.Domain
{
    public class GetDeviceStateHistoryHandler : IRequestHandler<GetDeviceStateHistoryRequest, IEnumerable<DeviceState>>
    {
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly ILogger<GetDeviceStateHistoryHandler> _logger;

        public GetDeviceStateHistoryHandler(IGatewayConnectionManager connectionManager, ILogger<GetDeviceStateHistoryHandler> logger)
        {
            _connectionManager = connectionManager;
            _logger = logger;
        }
        
        public async Task<IEnumerable<DeviceState>> Handle(GetDeviceStateHistoryRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("GetDeviceStateHistoryHandler called");

            var connection = _connectionManager.GetConnectionByHubId(request.HubId);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }

            return await connection.GetDeviceStateHistory(request.DeviceId, request.Start, request.End,
                request.IntervalSeconds, request.Count);
        }
    }
}