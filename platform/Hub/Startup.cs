using System;
using Hub.Config;
using Hub.Data;
using Hub.Server;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using MQTTnet.AspNetCore.Extensions;
using Shared;

namespace Hub
{
    public class Startup
    {
        private IConfiguration Configuration { get; }
        
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }
        
        public void ConfigureServices(IServiceCollection services)
        {
            services
                .AddHostedMqttServer(mqttServer => mqttServer.WithoutDefaultEndpoint())
                .AddMqttConnectionHandler()
                .AddConnections();

            services.AddRouting(options => options.LowercaseUrls = true);

            services.AddCors();
            
            services.AddMediatR(typeof(Startup));
            services.AddSwaggerGen(c =>
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "IoT Hub - API", Version = "v1" })             
            );

            
            services.AddOptions<HubConfig>().Bind(Configuration.GetSection("HubConfig"));
            services.AddOptions<StorageConfig>().Bind(Configuration.GetSection("StorageConfig"));
            
            const string serverConnectionConfigKey = "ServerConnectionConfig";
            var connectionOptions = Configuration.GetSection(serverConnectionConfigKey).Get<ServerConnectionConfig>();
            services.AddOptions<ServerConnectionConfig>().Bind(Configuration.GetSection(serverConnectionConfigKey));
            
            services.AddSignalR(
                options =>
                {
                    options.EnableDetailedErrors = true;
                    options.HandshakeTimeout = TimeSpan.FromSeconds(connectionOptions.HandshakeTimeout);
                    options.ClientTimeoutInterval = TimeSpan.FromSeconds(2 * connectionOptions.KeepAliveTimeout);
                    options.KeepAliveInterval = TimeSpan.FromSeconds(connectionOptions.KeepAliveTimeout);
                });
            
            services.AddHostedService<ServerConnection>();
            services.AddHostedService<MqttConnectionManager>();
            services.AddHostedService<LocalServiceDiscovery>();
            services.AddHostedService<HubBroadcaster>();
            
            services.AddSingleton<IDeviceService, DeviceService>();
            services.AddSingleton<IApiBroadcaster, ApiBroadcaster>();
            services.AddSingleton<IStateRepository, StateRepository>();

            services.AddControllers();
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
             
            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });

            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHub<GatewayHub>("/hub");
            });

            app.UseMqttServer(_ => { });
        }
    }
}
