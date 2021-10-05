import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:iot_client/models/connection/index.dart';
import 'package:iot_client/services/discovery/index.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class IAddressResolver {
  Stream<HubAddress> getAddress();
  Future init();
}

class WebAddressResolver implements IAddressResolver {
  final remoteDiscovery = RemoteHubDiscovery();

  @override
  Stream<HubAddress> getAddress() {
    return remoteDiscovery.getHubAddresses();
  }

  @override
  Future init() async {}
}

class AddressResolver implements IAddressResolver {
  final localDiscovery = LocalHubDiscovery();
  final remoteDiscovery = RemoteHubDiscovery();
  final logger = Logger("AddressResolver");

  late Stream<HubAddress> _hubUrlStream;

  @override
  Future init() async {
    var currentConnectivity = await Connectivity().checkConnectivity();
    _hubUrlStream = Connectivity()
        .onConnectivityChanged
        .startWith(currentConnectivity)
        .switchMap((result) {
      logger.info('Connectivity changed to: $result');
      switch (result) {
        case ConnectivityResult.wifi:
          return localDiscovery.getHubAddresses();
        case ConnectivityResult.mobile:
          return remoteDiscovery.getHubAddresses();
        default:
          return const Stream<HubAddress>.empty();
      }
    }).shareReplay(maxSize: 1);
  }

  @override
  Stream<HubAddress> getAddress() {
    return _hubUrlStream;
  }
}
