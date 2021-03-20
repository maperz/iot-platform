using MediatR;

namespace Hub.Domain
{
    public class SetSpeedRequest : IRequest
    {
        public double Speed { get; set; }
    }
}