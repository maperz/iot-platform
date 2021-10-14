import 'dart:io';

import 'package:iot_client/models/connection/index.dart';

import 'hub_discovery.dart';
import 'mdns/index.dart';
import 'remote_hub_discovery.dart';

class LocalHubDiscovery implements HubDiscovery {
  static const String serviceName = '_iothub._tcp';

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
    } else {
      await _clearCachedAddress();
      var discovery = RemoteHubDiscovery();
      var remoteAddress = await discovery.getHubAddresses().first;
      yield remoteAddress;
    }
  }

  Future _saveAddressToCache(HubAddress address) async {
    _cachedAddress = address;
  }

  Future _clearCachedAddress() async {
    _cachedAddress = null;
  }

  Future<HubAddress?> _loadCachedAddress() async {
    return _cachedAddress;
  }

  Future<HubAddress?> _discoverLocalAddressViaMDNS() async {
    IMDNSClient mdnsClient =
        Platform.isIOS ? NativeMDNSClient() : DartMDNSClient();

    var result = await mdnsClient.discoverService(serviceName);
    if (result == null) {
      return null;
    }

    return HubAddress("http", result.address, result.port, false);
  }
}
