using System;
using System.Threading;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace EmpoweredSignalR.Tests.Hub
{
    public class HubDriver<THub> : IDisposable where THub : EmpoweredHub 
    {
        private readonly IHost _host;
        private CancellationTokenSource _cancellationTokenSource;
        
        public HubDriver(int port = 5000)
        {
            _host = Host.CreateDefaultBuilder()
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseKestrel(
                        o =>
                        {
                            o.ListenAnyIP(port);
                        });
                    webBuilder.ConfigureServices(
                        services =>
                        {
                            services.AddSignalR(opt => opt.EnableDetailedErrors = true);
                        }
                    );

                    webBuilder.Configure(app =>
                    {
                        app.UseRouting();
                        app.UseEndpoints(endpoints =>
                        {
                            endpoints.MapHub<THub>("/hub");
                        });
                    });
                }).Build();
        }
        
        public void Start()
        {
            if (_cancellationTokenSource != null)
            {
                throw new Exception("HubDriver already running");
            }
            
            _cancellationTokenSource = new CancellationTokenSource();
            _host.RunAsync(_cancellationTokenSource.Token);
        }

        public void Stop()
        {
            if (_cancellationTokenSource == null)
            { 
                throw new Exception("HubDriver is not running");
            }
            
            _cancellationTokenSource.Cancel();
            _cancellationTokenSource = null;
        }

        public void Dispose()
        {
            if (_cancellationTokenSource == null) return;
            
            _cancellationTokenSource.Cancel();
            _cancellationTokenSource = null;
        }
    }
}