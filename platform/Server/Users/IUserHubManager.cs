using System.Threading.Tasks;

namespace Server.Users
{
    public interface IUserHubManager
    {
        Task<string?> GetHubForUser(string userId);

        Task AssignHubToUser(string userId, string hubId);

        Task<bool> RemoveHubFromUser(string userId, string hubId);
    }
}