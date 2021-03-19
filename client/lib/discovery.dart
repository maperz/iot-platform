import 'package:multicast_dns/multicast_dns.dart';

class LocalHubDiscovery {
  static const String service = '_sc_hub._tcp';

  Future<String> discoverAddress() async {
    final MDnsClient client = MDnsClient();
    await client.start();
    try {
      await for (PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(service))) {
        await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          String name = srv.target;
          int port = srv.port;
          await for (IPAddressResourceRecord record
              in client.lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv4(name))) {
            return 'http://${record.address.host}:$port';
          }

          await for (IPAddressResourceRecord record
              in client.lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv6(name))) {
            return 'http://${record.address.host}:$port';
          }
        }
      }
    } finally {
      print("Quitting discovery");
      client.stop();
    }
    return null;
  }
}
