using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Server.Config;
using Server.Connection;
using Server.Users;

namespace Server
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
            services.AddCors();
            
            services.AddOptions<StorageConfig>().Bind(Configuration.GetSection("StorageConfig"));

            var connectionSection = Configuration.GetSection("ConnectionsConfig");
            var connectionsConfig = connectionSection.Get<ConnectionsConfig>();
            services.AddOptions<ConnectionsConfig>().Bind(connectionSection);
            
            var authSection = Configuration.GetSection("AuthConfig");
            var authConfig = authSection.Get<AuthConfig>();
            services.AddOptions<AuthConfig>().Bind(authSection);
            
            services    
                .AddAuthentication( options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.Authority = authConfig.JwtAuthority;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = authConfig.JwtIssuer,
                        ValidateAudience = true,
                        ValidAudience = authConfig.JwtAudience,
                        ValidateLifetime = true
                    };
                    
                    options.Events = new JwtBearerEvents
                    {
                        OnMessageReceived = context =>
                        {
                            var accessToken = context.Request.Query["access_token"];
                            // Check if the request is for the hub
                            var path = context.HttpContext.Request.Path;
                            if (!string.IsNullOrEmpty(accessToken) &&
                                (path.StartsWithSegments("/hub")))
                            {
                                context.Token = accessToken;
                            }
                            return Task.CompletedTask;
                        }
                    };
                });
            
            services.AddSignalR(
                options =>
                {                    
                    options.EnableDetailedErrors = true;
                    options.HandshakeTimeout = TimeSpan.FromSeconds(connectionsConfig.HandshakeTimeout);
                    options.ClientTimeoutInterval = TimeSpan.FromSeconds(2 * connectionsConfig.KeepAliveTimeout);
                    options.KeepAliveInterval = TimeSpan.FromSeconds(connectionsConfig.KeepAliveTimeout);
                });
            
            services.AddSingleton<IGatewayConnectionManager, GatewayConnectionManager>();
            services.AddSingleton<IUserHubManager, UserHubManager>();
            
            services.AddMediatR(typeof(Startup));

            services.AddControllers();
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            
            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });
            
            app.UseCors(builder => builder
                .AllowAnyOrigin()
                .AllowAnyHeader()
                .AllowAnyMethod());
            
            app.UseRouting();
            
            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHub<ServerHub>("/hub");
            });
        }
    }
}
