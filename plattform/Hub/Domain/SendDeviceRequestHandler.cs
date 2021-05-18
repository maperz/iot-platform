using System;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using MQTTnet.Server;

namespace Hub.Domain
{
    public class SendDeviceRequestHandler : AsyncRequestHandler<SendDeviceRequest>
    {
        private readonly IMqttServer _mqttServer;
        private readonly ILogger<SendDeviceRequestHandler> _logger;

        public SendDeviceRequestHandler(IMqttServer mqttServer, ILogger<SendDeviceRequestHandler> logger)
        {
            _mqttServer = mqttServer;
            _logger = logger;
        }
        
        protected override async Task Handle(SendDeviceRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Sending request to: {DeviceId}, Name = {Request}", request.DeviceId, request.Name);
            await _mqttServer.PublishAsync(request.DeviceId + "/r/" + request.Name, request.Payload);
        }
    }
}