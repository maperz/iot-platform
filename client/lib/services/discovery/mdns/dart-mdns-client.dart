import 'package:logging/logging.dart';
import 'package:multicast_dns/multicast_dns.dart';

import 'mdns-client.dart';

class DartMDNSClient implements IMDNSClient {
  var logger = new Logger("MDNSClient");

  @override
  Future<MDNSResult?> discoverService(String serviceName) async {
    final MDnsClient client = MDnsClient();

    logger.info("Running mDNS discovery for '$serviceName'");
    await client.start();
    try {
      while (true) {
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
        await Future.delayed(Duration(seconds: 1));
      }
    } finally {
      client.stop();
    }
  }
}
