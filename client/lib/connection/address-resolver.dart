import 'dart:async';

import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/local-hub-discovery.dart';
import 'package:curtains_client/discovery/remote-hub-discovery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

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

  BehaviorSubject<ConnectivityResult>? _connectivity;
  late Stream<HubAddress> _hubUrlStream;

  Future init() async {
    if (_connectivity == null) {
      _connectivity =
          BehaviorSubject.seeded(await Connectivity().checkConnectivity());
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        _connectivity!.add(result);
      });

      _hubUrlStream = _connectivity!.switchMap((result) {
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
  }

  @override
  Stream<HubAddress> getAddress() {
    return _hubUrlStream;
  }

  dispose() {
    _connectivity?.close();
  }
}
