using MediatR;

namespace Hub.Domain
{
    public class SendDeviceRequest : DeviceRequest, IRequest
    {
        public string Name { get; set; }
        
        public string Payload { get; set; }
    }
}