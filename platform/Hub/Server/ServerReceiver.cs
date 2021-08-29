using System.Collections.Generic;
using System.Threading.Tasks;
using EmpoweredSignalR;
using Hub.Domain;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared;

namespace Hub.Server
{
    public class ServerReceiver : Receiver
    {
        private readonly IMediator _mediator;
        private readonly ILogger _logger;
        
        public ServerReceiver(IMediator mediator, ILogger logger)
        {
            _mediator = mediator;
            _logger = logger;
        }
        
        public async Task<IEnumerable<DeviceState>> GetDeviceStates()
        {
            _logger.LogInformation("GetDeviceListRequest request received");
            var deviceList = await _mediator.Send(new GetDeviceListRequest());
            return deviceList;
        }
        
        public async Task<IEnumerable<DeviceState>> GetDeviceStateHistory(ServerHubHistoryRequest request)
        {
            _logger.LogInformation("GetDeviceStateHistory request received");
            var deviceList = await _mediator.Send(new GetDeviceStateHistoryRequest()
            {
                DeviceId = request.DeviceId,
                Start = request.Start,
                End = request.End,
                IntervalSeconds = request.IntervalSeconds,
                Count = request.Count,
            });
            return deviceList;
        }
    }
}