using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Shared;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Hub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DevicesController : ControllerBase
    {
        private readonly IMediator _mediator;

        public DevicesController(IMediator mediator)
        {
            _mediator = mediator;
        }


        [HttpGet]
        public async Task<IEnumerable<DeviceState>> GetDeviceStates([FromQuery] IEnumerable<string>? devices = null)
        {
            var deviceQuery = devices?.ToList();
            var devicesList = await _mediator.Send(new GetDeviceListRequest());

            if (deviceQuery == null || deviceQuery.All(string.IsNullOrWhiteSpace))
			{
                return devicesList;
			}

            return devicesList.Where(device => deviceQuery.Contains(device.DeviceId));
        }
        
        [HttpGet("history")]
        public async Task<IEnumerable<DeviceState>> GetDeviceStateHistory([FromQuery] GetDeviceStateHistoryRequest request)
        {
            var deviceStates = await _mediator.Send(request);
            return deviceStates;
        }
        

        [HttpPost]
        public Task SendDeviceRequest([FromBody] SendDeviceRequest request)
        {
            return _mediator.Send(request);
        }
    }
}
