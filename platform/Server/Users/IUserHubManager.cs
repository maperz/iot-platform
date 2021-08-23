using System.Threading.Tasks;

namespace Server.Users
{
    public interface IUserHubManager
    {
        Task<string?> GetHubForUser(string userId);
    }
}