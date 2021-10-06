namespace Server.Config
{
    public class AuthConfig
    {
        public string JwtAuthority { get; init; } = "";

        public string JwtIssuer { get; init; } = "";

        public string JwtAudience { get; init; } = "";
    }
}