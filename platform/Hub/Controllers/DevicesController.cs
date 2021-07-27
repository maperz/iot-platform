using Hub.Domain;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Shared;
using System;
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

        public async Task<IEnumerable<DeviceState>> GetDevices([FromQuery] IEnumerable<string>? devices = null)
        {
            var devicesList = await _mediator.Send(new GetDeviceListRequest());

            if (devices == null || !devices.Where(x => !string.IsNullOrWhiteSpace(x)).Any())
			{
                return devicesList;
			}

            return devicesList.Where(device => devices.Contains(device.DeviceId));
        }

        [HttpPost]
        public Task SendDeviceRequest([FromBody] SendDeviceRequest request)
        {
            return _mediator.Send(request);
        }
    }
}
