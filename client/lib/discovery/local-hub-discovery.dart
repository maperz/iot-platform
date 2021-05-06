import 'dart:io';

import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/hub-discovery.dart';
import 'package:curtains_client/discovery/mdns/dart-mdns-client.dart';
import 'package:curtains_client/discovery/mdns/mdns-client.dart';
import 'package:curtains_client/discovery/mdns/native-mdns-client.dart';

class LocalHubDiscovery implements HubDiscovery {
  static const String SERVICE_NAME = '_iothub._tcp';

  HubAddress? _cachedAddress;

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

  Future<HubAddress?> _loadCachedAddress() async {
    return _cachedAddress;
  }

  Future<HubAddress?> _discoverLocalAddressViaMDNS() async {
    IMDNSClient mdnsClient = (Platform.isIOS || Platform.isAndroid)
        ? NativeMDNSClient()
        : DartMDNSClient();

    var result = await mdnsClient.discoverService(SERVICE_NAME);

    if (result == null) {
      return null;
    }

    return HubAddress("http", result.address, result.port);
  }
}
