using System.Collections.Generic;
using System.Threading.Tasks;

namespace Server.Users
{
    using UserHubMapping = Dictionary<string, string>;

    public class UserHubManager : IUserHubManager
    {
        private readonly UserHubMapping _userHubMapping = new()
        {
            {"N6K8dv4ekARQu17olArOQfUrbbS2", "EX4MPL3-HUB-1D"},
            {"izejtoxs1bZR1NBH7Ak7627fhI12", "EX4MPL3-HUB-1D"},
        };
        
        public Task<string?> GetHubForUser(string userId)
        {
            var hubId = _userHubMapping.GetValueOrDefault(userId);
            return Task.FromResult(hubId);
        } 
    }
}