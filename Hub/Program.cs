using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using MQTTnet.AspNetCore.Extensions;

namespace Hub
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseKestrel(
                        o =>
                        {
                            o.ListenAnyIP(1883, l => l.UseMqtt());
                            o.ListenAnyIP(5000);
                        });
                    webBuilder.UseStartup<Startup>();
                });
    }
}
