using MediatR;

namespace Hub.Domain
{
    public class SetNameRequest : DeviceRequest, IRequest
    {
        public string Name { get; set; } = "";
    }
}