using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Makaretu.Dns;

namespace DataPoller
{
    class HubServiceDiscovery
    {
        private readonly string _serviceName = "_iothub._tcp.local";

        public async Task<string?> GetHubAddress()
        {
            var query = new Message();
            query.Questions.Add(new Question { Name = _serviceName, Type = DnsType.ANY });
            var cancellation = new CancellationTokenSource(2000);

            try
            {
				using var mdns = new MulticastService();
				mdns.Start();
				var response = await mdns.ResolveAsync(query, cancellation.Token);

				var addressRecord = response.AdditionalRecords.OfType<ARecord>().First();
				var srvRecord = response.AdditionalRecords.OfType<SRVRecord>().First();

				var address = addressRecord.Address + ":" + srvRecord.Port;
				return address;
			}
            catch (Exception)
            {
                return null;
            }
        }

    }
}
