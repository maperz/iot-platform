using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub.Domain
{
    public class GetDeviceListHandler : IRequestHandler<GetDeviceListRequest, IEnumerable<DeviceState>>
    {
        private readonly IDeviceService _deviceService;
        private readonly ILogger<GetDeviceListHandler> _logger;

        public GetDeviceListHandler(IDeviceService deviceService, ILogger<GetDeviceListHandler> logger)
        {
            _deviceService = deviceService;
            _logger = logger;
        }
        
        public async Task<IEnumerable<DeviceState>> Handle(GetDeviceListRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Device List request Handler called");
            var deviceList = (await _deviceService.GetDeviceStates()).ToList();
            _logger.LogInformation("Queried {NumDevices} devices", deviceList.Count);
            return deviceList;
        }
    }
}