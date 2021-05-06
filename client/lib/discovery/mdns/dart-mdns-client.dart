import 'package:multicast_dns/multicast_dns.dart';

import 'mdns-client.dart';

class DartMDNSClient implements IMDNSClient {
  @override
  Future<MDNSResult?> discoverService(String serviceName) async {
    print("Running mDNS discovery");
    final MDnsClient client = MDnsClient();
    await client.start();
    try {
      await for (PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(serviceName))) {
        await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          String name = srv.target;
          int port = srv.port;
          await for (IPAddressResourceRecord record
              in client.lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv4(name))) {
            return new MDNSResult(record.address.host, port);
          }

          await for (IPAddressResourceRecord record
              in client.lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv6(name))) {
            return new MDNSResult(record.address.host, port);
          }
        }
      }
    } finally {
      print("Quitting discovery");
      client.stop();
    }
  }
}
