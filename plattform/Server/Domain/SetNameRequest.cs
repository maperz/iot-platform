using MediatR;

namespace Server.Domain
{
    public class SetNameRequest : HubDeviceRequest, IRequest
    {
        public string Name { get; set; } = "";
    }
}