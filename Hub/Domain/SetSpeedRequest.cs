using MediatR;

namespace Hub.Domain
{
    public class SetSpeedRequest : IRequest
    {
        public string DeviceId { get; set; }
        public double Speed { get; set; }
    }
}