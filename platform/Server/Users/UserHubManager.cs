using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Server.Config;

namespace Server.Users
{
    using UserHubMapping = Dictionary<string, string>;

    public class UserHubManager : IUserHubManager
    {
        private readonly MemoryCache _mappingCache = new(new MemoryCacheOptions());
        
        private IDbConnection Connection { get; }
        private readonly ILogger<UserHubManager> _logger;

        public UserHubManager(ILogger<UserHubManager> logger, IOptions<StorageConfig> storageConfig)
        {
            _logger = logger;
            Connection = new SqliteConnection(storageConfig.Value.ConnectionString);
            InitializeDatabase();
        }
        
        public async Task<string?> GetHubForUser(string userId)
        {
            if (_mappingCache.TryGetValue(userId, out string cachedHubId))
            {
                return cachedHubId;
            }

            var hubId = await TryGetUserHubIdFromDatabase(userId);

            if (hubId != null)
            {
                _mappingCache.Set(userId, hubId);
            }
            
            return hubId;
        }

        public async Task AssignHubToUser(string userId, string hubId)
        {
            _mappingCache.Remove(userId);

            try
            {
                const string sql = @"INSERT INTO user_hub_mappings VALUES (@userId, @hubId);";
                using var db = Connection;
                await db.ExecuteAsync(sql, new {userId, hubId});
            }
            catch
            {
                throw new Exception("Failed set Hub for User: " + userId + " Hub: "+ hubId);
            }
        }

        public async Task<bool> RemoveHubFromUser(string userId, string hubId)
        {
            _mappingCache.Remove(userId);

            const string sql = @"DELETE FROM user_hub_mappings WHERE UserId = @userId AND HubId = @hubId;";
            using var db = Connection;
            await db.ExecuteAsync(sql, new {userId, hubId});
            return true;
        }

        private async Task<string?> TryGetUserHubIdFromDatabase(string userId)
        {
            const string sql = @"SELECT HubId FROM user_hub_mappings WHERE UserId = @userId;";
            using var db = Connection;
            var hubId = (await db.QueryAsync<string>(sql, new{ userId })).FirstOrDefault();
            return hubId;
        }
        
        private void InitializeDatabase()
        {
            try
            {
                using var db = Connection;
                const string sql = @"CREATE TABLE IF NOT EXISTS user_hub_mappings (UserId TEXT NOT NULL PRIMARY KEY UNIQUE, HubId TEXT NOT NULL);";
                db.Execute(sql);
            }
            catch (Exception e)
            {
                _logger.LogError("Failed to setup database: {Exception}", e);
            }
        }
    }
}