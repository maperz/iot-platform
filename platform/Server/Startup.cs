using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using OpenIddict.Abstractions;
using Server.Connection;
using Server.Data;
using Server.Data.Entities;

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
            
            services.Configure<AppSettings>(Configuration);
            var appSettings = new AppSettings();
            Configuration.Bind(appSettings);
            services.AddSingleton(appSettings);
            
            string firebaseAppId = appSettings.FirebaseAppId;
            services
                .AddAuthentication( options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.Authority = $"https://securetoken.google.com/{firebaseAppId}";
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = $"https://securetoken.google.com/{firebaseAppId}",
                        ValidateAudience = true,
                        ValidAudience = firebaseAppId,
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
                    options.HandshakeTimeout = TimeSpan.FromSeconds(appSettings.HandshakeTimeout);
                    options.ClientTimeoutInterval = TimeSpan.FromSeconds(2 * appSettings.KeepAliveTimeout);
                    options.KeepAliveInterval = TimeSpan.FromSeconds(appSettings.KeepAliveTimeout);
                });
            
            services.AddSingleton<IGatewayConnectionManager, GatewayConnectionManager>();
            services.AddSingleton<IUserHubManager, UserHubManager>();
            
            services.AddMediatR(typeof(Startup));
            
            
            services.AddDbContext<ApplicationDbContext>(options => 
            {
                options.UseSqlite(appSettings.ConnectionStrings.DefaultConnection);
                options.UseOpenIddict();
            });
            
            services.AddDefaultIdentity<ApplicationUser>()
                .AddEntityFrameworkStores<ApplicationDbContext>()
                .AddDefaultTokenProviders();
            
            services.Configure<IdentityOptions>(options =>
            {
                options.ClaimsIdentity.UserNameClaimType = OpenIddictConstants.Claims.Name;
                options.ClaimsIdentity.UserIdClaimType = OpenIddictConstants.Claims.Subject;
                options.ClaimsIdentity.RoleClaimType = OpenIddictConstants.Claims.Role;
            });

            services.AddOpenIddict()
                .AddCore(options =>
                {
                    options.UseEntityFrameworkCore()
                        .UseDbContext<ApplicationDbContext>();
                })
                .AddServer(options =>
                {
                    options.SetAuthorizationEndpointUris("/connect/authorize")
                        .SetDeviceEndpointUris("/connect/device")
                        .SetLogoutEndpointUris("/connect/logout")
                        .SetTokenEndpointUris("/connect/token")
                        .SetUserinfoEndpointUris("/connect/userinfo")
                        .SetVerificationEndpointUris("/connect/verify");
                    
                    options.AllowAuthorizationCodeFlow()
                        .AllowDeviceCodeFlow()
                        .AllowPasswordFlow()
                        .AllowRefreshTokenFlow();

                    // Mark the "email", "profile", "roles" and "demo_api" scopes as supported scopes.
                    options.RegisterScopes(OpenIddictConstants.Scopes.Email, OpenIddictConstants.Scopes.Profile,
                        OpenIddictConstants.Scopes.Roles, "iot_api");

                    // Register the signing and encryption credentials.
                    options.AddDevelopmentEncryptionCertificate()
                        .AddDevelopmentSigningCertificate();

                    // Force client applications to use Proof Key for Code Exchange (PKCE).
                    options.RequireProofKeyForCodeExchange();

                    // Register the ASP.NET Core host and configure the ASP.NET Core-specific options.
                    options.UseAspNetCore()
                        .EnableStatusCodePagesIntegration()
                        .EnableAuthorizationEndpointPassthrough()
                        .EnableLogoutEndpointPassthrough()
                        .EnableTokenEndpointPassthrough()
                        .EnableUserinfoEndpointPassthrough()
                        .EnableVerificationEndpointPassthrough()
                        .DisableTransportSecurityRequirement();

                    options.AcceptAnonymousClients();
                });
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
