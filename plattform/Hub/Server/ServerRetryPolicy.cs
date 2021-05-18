using System;
using System.Linq;
using Microsoft.AspNetCore.SignalR.Client;

namespace Hub.Server
{
    public class ServerRetryPolicy : IRetryPolicy
    {
        private readonly TimeSpan[] _intervals = new[]
        {
            TimeSpan.FromSeconds(1),
            TimeSpan.FromSeconds(5),
            TimeSpan.FromSeconds(10),
            TimeSpan.FromSeconds(15),
            TimeSpan.FromSeconds(15),
            TimeSpan.FromSeconds(30),
            TimeSpan.FromSeconds(30)
        };
        
        public TimeSpan? NextRetryDelay(RetryContext retryContext)
        {
            return retryContext.PreviousRetryCount > _intervals.Length ? _intervals.Last() : _intervals[retryContext.PreviousRetryCount];
        }
    }
}