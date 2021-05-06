import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/hub-discovery.dart';
import 'package:multicast_dns/multicast_dns.dart';
// import 'package:curtains_client/discovery/patched-mdns-client.dart';

class LocalHubDiscovery implements HubDiscovery {
  static const String service = '_iothub._tcp';

  HubAddress _cachedAddress;

  @override
  Stream<HubAddress> getHubAddresses() async* {
    var cachedAddress = await _loadCachedAddress();
    if (cachedAddress != null) {
      yield cachedAddress;
    }
    var discoveredAddress = await _discoverLocalAddressViaMDNS();
    if (discoveredAddress != null) {
      await _saveAddressToCache(discoveredAddress);
      yield discoveredAddress;
    }
  }

  Future _saveAddressToCache(HubAddress address) async {
    _cachedAddress = address;
  }

  Future<HubAddress> _loadCachedAddress() async {
    return _cachedAddress;
  }

  Future<HubAddress> _discoverLocalAddressViaMDNS() async {
    print("Running mDNS discovery");
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
            return new HubAddress("http", record.address.host, port);
          }

          await for (IPAddressResourceRecord record
              in client.lookup<IPAddressResourceRecord>(
                  ResourceRecordQuery.addressIPv6(name))) {
            return new HubAddress("http", record.address.host, port);
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
