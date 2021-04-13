using MediatR;

namespace Hub.Domain
{
    public class SetSpeedRequest : DeviceRequest, IRequest
    {
        public double Speed { get; set; }
    }
}