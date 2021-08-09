import 'dart:async';

import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/local-hub-discovery.dart';
import 'package:curtains_client/discovery/remote-hub-discovery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class IAddressResolver {
  Stream<HubAddress> getAddress();
  Future init();
}

class WebAddressResolver implements IAddressResolver {
  final remoteDiscovery = new RemoteHubDiscovery();

  @override
  Stream<HubAddress> getAddress() {
    return remoteDiscovery.getHubAddresses();
  }

  Future init() async {}
}

class AddressResolver implements IAddressResolver {
  final localDiscovery = new LocalHubDiscovery();
  final remoteDiscovery = new RemoteHubDiscovery();
  final logger = new Logger("AddressResolver");

  late Stream<HubAddress> _hubUrlStream;

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
          return Stream<HubAddress>.empty();
      }
    }).asBroadcastStream();
  }

  @override
  Stream<HubAddress> getAddress() {
    return _hubUrlStream;
  }
}
