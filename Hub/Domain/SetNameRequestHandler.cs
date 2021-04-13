using System;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using MQTTnet.Server;

namespace Hub.Domain
{
    public class SetNameRequestHandler : AsyncRequestHandler<SetNameRequest>
    {
        private readonly IMqttServer _mqttServer;
        private readonly ILogger<SetNameRequestHandler> _logger;

        public SetNameRequestHandler(IMqttServer mqttServer, ILogger<SetNameRequestHandler> logger)
        {
            _mqttServer = mqttServer;
            _logger = logger;
        }
        
        protected override async Task Handle(SetNameRequest request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("Changing name requested for client: {String} to Name: '{String}' ",
                request.DeviceId, request.Name);
            
            await _mqttServer.PublishAsync(request.DeviceId + "/r/name", request.Name);
        }
    }
}