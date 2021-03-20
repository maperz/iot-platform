using System;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using MQTTnet.Server;

namespace Hub.Domain
{
    public class SetSpeedRequestHandler : AsyncRequestHandler<SetSpeedRequest>
    {
        private readonly IMqttServer _mqttServer;
        private readonly ILogger<SetSpeedRequestHandler> _logger;

        public SetSpeedRequestHandler(IMqttServer mqttServer, ILogger<SetSpeedRequestHandler> logger)
        {
            _mqttServer = mqttServer;
            _logger = logger;
        }
        
        protected override async Task Handle(SetSpeedRequest request, CancellationToken cancellationToken)
        {
            var speed = request.Speed;
            
            _logger.LogInformation("Received Speed value: {Double}", speed);

            speed = Math.Max(-1.0, Math.Min(1.0, speed));

            await _mqttServer.PublishAsync("speed", speed.ToString(CultureInfo.InvariantCulture));
        }
    }
}