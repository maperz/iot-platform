using Hub.Server;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MQTTnet.AspNetCore.Extensions;

namespace Hub
{
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services
                .AddHostedMqttServer(mqttServer => mqttServer.WithoutDefaultEndpoint())
                .AddMqttConnectionHandler()
                .AddConnections();

            services.AddCors();
            
            services.AddSignalR();

            services.AddMediatR(typeof(Startup));

            services.AddHostedService<ServerConnection>();
            services.AddHostedService<MqttConnectionManager>();
            
            services.AddSingleton<IDeviceService, DeviceService>();
            services.AddSingleton<IDeviceChangeBroadcaster, DeviceChangeBroadcaster>();
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            
            app.UseRouting();
            
            app.UseCors(builder => builder
                .AllowAnyOrigin()
                .AllowAnyHeader()
                .AllowAnyMethod());
            
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapHub<GatewayHub>("/hub");
            });

            app.UseMqttServer(server => { });

            var serviceDiscovery = new LocalServiceDiscovery();
            serviceDiscovery.Advertise("CurtainHub", "_sc_hub._tcp", 5000);
        }
    }
}
