import 'dart:async';

import 'package:curtains_client/discovery/local-hub-discovery.dart';
import 'package:curtains_client/discovery/remote-hub-discovery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:curtains_client/utils/platform.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

abstract class IAddressResolver {
  Stream<String?> getHubUrl();
  Future init();
}

class WebAddressResolver implements IAddressResolver {
  final remoteDiscovery = new RemoteHubDiscovery();

  @override
  Stream<String?> getHubUrl() {
    return remoteDiscovery
        .getHubAddresses()
        .map((address) => address.toString());
  }

  Future init() async {}
}

class AddressResolver implements IAddressResolver {
  final localDiscovery = new LocalHubDiscovery();
  final remoteDiscovery = new RemoteHubDiscovery();

  BehaviorSubject<ConnectivityResult>? _connectivity;
  Stream<String?>? _hubUrlStream;

  Future init() async {
    if (_connectivity == null) {
      _connectivity =
          BehaviorSubject.seeded(await Connectivity().checkConnectivity());
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        _connectivity!.add(result);
      });

      _hubUrlStream = _connectivity!.switchMap((result) {
        print("Connectivity changed to: " + result.toString());

        switch (result) {
          case ConnectivityResult.wifi:
            return localDiscovery
                .getHubAddresses()
                .map((address) => address.toString());
          case ConnectivityResult.mobile:
            return remoteDiscovery
                .getHubAddresses()
                .map((address) => address.toString());
          default:
            return Stream.value(null);
        }
      });
    }
  }

  @override
  Stream<String?> getHubUrl() {
    if (_hubUrlStream == null) {
      throw new Error();
    }

    return _hubUrlStream!;
  }

  dispose() {
    _connectivity?.close();
  }
}
