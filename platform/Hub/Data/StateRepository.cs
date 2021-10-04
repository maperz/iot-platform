using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Shared;
using Dapper;
using Hub.Config;
using Hub.Data.Entities;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Hub.Data
{
    public class StateRepository : IStateRepository
    {
        private readonly Dictionary<string, DeviceState> _deviceStateCache = new();
        private readonly string _databasePath;
        private readonly ILogger<StateRepository> _logger;
        private readonly TimeSpan _devicePersistenceInterval;

        private IDbConnection Connection => new SqliteConnection("Data Source=" + _databasePath);

        public StateRepository(ILogger<StateRepository> logger, IOptions<StorageConfig> storageConfig)
        {
            _logger = logger;
            
            _databasePath = storageConfig.Value.DatabasePath;
            _devicePersistenceInterval = TimeSpan.FromSeconds(storageConfig.Value.StateStorageIntervalSeconds);
            
            SetupDatabase();
            InitializeCache();
        }
        
        public async Task SetDeviceState(DeviceState state)
        {
            lock (_deviceStateCache)
            {
                _deviceStateCache[state.DeviceId] = state;
            }

            await SaveStateToDatabase(state);
        }

        public Task<DeviceState?> GetLastDeviceState(string deviceId)
        {
            lock (_deviceStateCache)
            {
                return Task.FromResult(_deviceStateCache.GetValueOrDefault(deviceId));
            }
        }

        public async Task<IEnumerable<DeviceState>> GetStateHistoryForDevice(string deviceId, DateTime? start = null, DateTime? end = null, int? intervalSeconds = null, int? count = null)
        {
            var sql = (start, end) switch
            {
                (null, null) => "SELECT * FROM DeviceStates WHERE DeviceId = @id",
                (_, null) => "SELECT * FROM DeviceStates WHERE DeviceId = @id AND LastUpdate >= @start",
                (null, _) => "SELECT * FROM DeviceStates WHERE DeviceId = @id AND LastUpdate <= @end",
                (_, _) => "SELECT * FROM DeviceStates WHERE DeviceId = @id AND LastUpdate BETWEEN @start AND @end"
            };

            var currentInterval = (int)_devicePersistenceInterval.TotalSeconds;
            if (intervalSeconds > currentInterval)
            {
                var demandedInterval = intervalSeconds.GetValueOrDefault();
                var actualInterval = demandedInterval - (demandedInterval % currentInterval);

                if (actualInterval != currentInterval)
                {
                    var steps = actualInterval / currentInterval;
                    sql = "SELECT * FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY LastUpdate) AS RowNum FROM (" + sql + ")) WHERE RowNum % " + steps + " = 1";
                }
            }

            if (count != null)
            {
                sql = "SELECT * FROM (SELECT * FROM (" +  sql + ") ORDER BY LastUpdate DESC LIMIT " + count + ") ORDER BY LastUpdate ASC";
            }
            
            using var db = Connection;
            var states = await db.QueryAsync<StateEntity>(sql, new{id = deviceId, start, end});
            return states?.Select(Mapping.StateFromEntity) ?? Array.Empty<DeviceState>();
        }

        public Task<IEnumerable<DeviceState>> GetLastDeviceStates()
        {
            lock (_deviceStateCache)
            {
                return Task.FromResult(_deviceStateCache.Values.Where(x => x.Info != null));
            }
        }
        
        private void InitializeCache()
        {
            try
            {
                using var db = Connection;
                const string sql = "SELECT *, MAX(LastUpdate) FROM DeviceStates GROUP BY DeviceId;";
                var states = db.Query<StateEntity>(sql).Select(Mapping.StateFromEntity);
                lock (_deviceStateCache)
                {
                    foreach (var deviceState in states)
                    {
                        _deviceStateCache[deviceState.DeviceId] = deviceState;
                    }
                }
            }
            catch (Exception e)
            {
                _logger.LogError("Failed to initialize cache from database: {Exception}", e);
            }
            
        }
        
        private async Task SaveStateToDatabase(DeviceState state)
        {

            if (string.IsNullOrWhiteSpace(state.State))
            {
                return;
            }
            
            var newEntity = Mapping.StateToEntity(state);
                
            using var db = Connection;
            db.Open();
            using var transaction = db.BeginTransaction();
            
            try
            {
                const string lastTwoStatesSql = "SELECT * FROM DeviceStates WHERE DeviceId=@id ORDER BY LastUpdate DESC LIMIT 2;";
                var recentTwoStates = (await db.QueryAsync<StateEntity>(lastTwoStatesSql, new { id = newEntity.DeviceId }, transaction)).ToList();

                switch (recentTwoStates.Count)
                {
                    case > 0 when recentTwoStates[0] == newEntity:
                        return;
                    case 2 when (recentTwoStates[0].LastUpdate - recentTwoStates[1].LastUpdate) < _devicePersistenceInterval:
                    {
                        const string deleteRowSql = @"DELETE FROM DeviceStates WHERE Id=@id";
                        await db.ExecuteAsync(deleteRowSql, new {id = recentTwoStates[0].Id }, transaction);
                        break;
                    }
                }

                const string insertSql =
                    @"INSERT INTO DeviceStates (DeviceId, State, LastUpdate, Name, Version, Type) VALUES (@DeviceId, @State, @LastUpdate, @Name, @Version, @Type);";
                await db.ExecuteAsync(insertSql, newEntity, transaction);
                        
                transaction.Commit();
            }
            catch (Exception e)
            {
                _logger.LogError("Failed to save state to database: {Exception}", e);
                transaction.Rollback();
            }
        }

        private void SetupDatabase()
        {
            try
            {
                using var db = Connection;
                const string sql =
                    @"CREATE TABLE IF NOT EXISTS DeviceStates (Id INTEGER PRIMARY KEY AUTOINCREMENT, DeviceId TEXT NOT NULL, State TEXT, LastUpdate TEXT, Name TEXT, Version TEXT, Type TEXT);";
                db.Execute(sql);
            }
            catch (Exception e)
            {
                _logger.LogError("Failed to setup database: {Exception}", e);
            }
        }
    }
}