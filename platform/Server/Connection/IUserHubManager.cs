using System.Threading.Tasks;

namespace Server.Connection
{
    public interface IUserHubManager
    {
        Task<string?> GetHubForUser(string userId);
    }
}