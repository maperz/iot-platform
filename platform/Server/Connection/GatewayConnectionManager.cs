using System.Collections.Generic;
using System.Threading;
using Microsoft.AspNetCore.SignalR;

namespace Server.Connection
{
    public class GatewayConnectionManager : IGatewayConnectionManager
    {
        private readonly ReaderWriterLockSlim _lock = new ();
        private readonly Dictionary<string, IGatewayConnection> _connections = new ();

        private readonly IHubContext<ServerHub> _context;

        public GatewayConnectionManager(IHubContext<ServerHub> context)
        {
            _context = context;
        }
        
        public void AddConnection(string connectionId)
        {
            _lock.EnterWriteLock();
            try
            {
                if (_connections.ContainsKey(connectionId))
                {
                    return;
                }

                _connections.Add(connectionId, new GatewayConnection(connectionId, _context));
            }
            finally
            {
                _lock.ExitWriteLock();
            }
        }
        
        public bool RemoveConnection(string connectionId)
        {
            _lock.EnterWriteLock();
            try
            {
                return _connections.Remove(connectionId);
            }
            finally
            {
                _lock.ExitWriteLock();
            }
        }

        public IGatewayConnection? GetConnection(string connectionId)
        {
            
            _lock.EnterReadLock();
            try
            {
                return _connections.GetValueOrDefault(connectionId);
            }
            finally
            {
                _lock.ExitReadLock();
            }
        }
    }
}