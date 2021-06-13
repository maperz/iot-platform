using MediatR;

namespace Server.Domain
{
    public class SendHubDeviceRequest : HubDeviceRequest, IRequest
    {
        public string Name { get; set; } = "";

        public string Payload { get; set; } = "";
    }
}