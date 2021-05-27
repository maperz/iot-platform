using System.Collections.Generic;
using MediatR;
using Shared;

namespace Server.Domain
{
    public class GetDeviceListRequest: HubRequest, IRequest<IEnumerable<DeviceState>>
    {
        
    }
}