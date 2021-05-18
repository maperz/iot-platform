using MediatR;

namespace Hub.Domain
{
    public class DeviceRequest
    {
        public string DeviceId { get; set; } = "";
    }
}