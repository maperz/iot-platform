using System.Collections.Generic;
using MediatR;
using Shared;

namespace Hub.Domain
{
    public class GetDeviceListRequest: IRequest<IEnumerable<DeviceState>>
    {
        
    }
}