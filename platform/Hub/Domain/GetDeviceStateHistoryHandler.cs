using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub.Domain
{
    public class GetDeviceStateHistoryHandler : IRequestHandler<GetDeviceStateHistoryRequest, IEnumerable<DeviceState>>
    {
        private readonly IDeviceService _deviceService;
        private readonly ILogger<GetDeviceStateHistoryHandler> _logger;

        public GetDeviceStateHistoryHandler(IDeviceService deviceService, ILogger<GetDeviceStateHistoryHandler> logger)
        {
            _deviceService = deviceService;
            _logger = logger;
        }
        
        public Task<IEnumerable<DeviceState>> Handle(GetDeviceStateHistoryRequest request, CancellationToken cancellationToken)
        {
            return _deviceService.GetDeviceStateHistory(request.DeviceId, request.Start, request.End, request.IntervalSeconds, request.Count);
        }
    }
}