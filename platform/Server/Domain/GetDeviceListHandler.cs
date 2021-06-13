using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Server.Connection;
using Shared;

namespace Server.Domain
{
    public class GetDeviceListHandler : IRequestHandler<GetDeviceListRequest, IEnumerable<DeviceState>>
    {
        private readonly IGatewayConnectionManager _connectionManager;
        private readonly ILogger<GetDeviceListHandler> _logger;

        public GetDeviceListHandler(IGatewayConnectionManager connectionManager, ILogger<GetDeviceListHandler> logger)
        {
            _connectionManager = connectionManager;
            _logger = logger;
        }
        
        public async Task<IEnumerable<DeviceState>> Handle(GetDeviceListRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Device List request Handler called");

            var connection = _connectionManager.GetConnection(request.HubId);
            
            if (connection == null)
            {
                throw new NoConnectionException();
            }
            
            return await connection.GetDeviceList();
        }
    }
}