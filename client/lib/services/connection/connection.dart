import 'dart:async';

import 'package:iot_client/models/connection/index.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:iot_client/services/auth/auth_service.dart';
import 'package:iot_client/services/connection/address_resolver.dart';
import 'package:iot_client/services/connection/signalr/signalr_helper.dart';

typedef Json = Map<String, dynamic>;

class ConnectionStateData {
  final bool isConnected;
  final ConnectionInfo? info;
  const ConnectionStateData(this.isConnected, this.info);

  static const ConnectionStateData disconnected =
      ConnectionStateData(false, null);

  @override
  String toString() {
    var connected = isConnected ? "Connected" : "Disconnected";
    return "[$connected] $info";
  }
}

abstract class IConnectionService {
  Stream<ConnectionStateData> getConnectedState();

  Stream<bool> isConnected();

  Future<S> invoke<S>(String endpoint, {List<dynamic>? args});

  Stream<S> listenOn<S>(String endpoint);

  Future start();

  Future stop();
}

class ConnectionEndpoints {
  static const String connectionInfo = "ConnectionInfo";
}

class AddressTokenTuple {
  final HubAddress address;
  final String? token;
  AddressTokenTuple(this.address, this.token);
}

class ConnectionService implements IConnectionService {
  final logger = Logger('ConnectionService');
  final IAddressResolver addressResolver;
  final IAuthService authService;
  late final SignalRHelper signalR;

  late BehaviorSubject<ConnectionStateData> _connectionState;
  late BehaviorSubject<bool> _isConnected;
  late BehaviorSubject<ConnectionInfo?> _connectionInfo;

  ConnectionService({required this.addressResolver, required this.authService});

  StreamSubscription? _subscription;
  StreamSubscription? _addressTokenSubscription;

  @override
  Future start() async {
    _isConnected = BehaviorSubject.seeded(false);
    _connectionInfo = BehaviorSubject.seeded(null);
    _connectionState = BehaviorSubject.seeded(ConnectionStateData.disconnected);

    void onReconnecting(Exception? err) {
      _onConnectionStopped();
    }

    void onReconnected(String? id) {
      _onConnectionStarted();
    }

    signalR = SignalRHelper(
        onReconnecting: onReconnecting, onReconnected: onReconnected);

    _subscription = Rx.combineLatest2(
            _isConnected,
            _connectionInfo,
            (bool connected, ConnectionInfo? info) =>
                ConnectionStateData(info?.isConnected ?? false, info))
        .asBroadcastStream()
        .listen((stateDate) {
      _connectionState.add(stateDate);
    });

    var addressChanged = addressResolver.getAddress();
    var tokenChanged = authService
        .currentUser()
        .asyncMap((user) => user?.getIdToken() ?? Future.value(null))
        .distinct();

    StreamSubscription? lastConnectionInfoSub;

    _addressTokenSubscription = Rx.combineLatest2(
            addressChanged,
            tokenChanged,
            (HubAddress address, String? token) =>
                AddressTokenTuple(address, token))
        .distinct()
        .listen((change) async {
      var address = change.address;
      var token = change.token;

      final hubUrl = '$address/hub';

      logger.fine(
          "Handle connection to $hubUrl. Requires Auth: ${address.requiresAuthentication} and Token: ${token?.substring(0, 5)}...");

      await signalR.stop();
      _onConnectionStopped();

      if (address.requiresAuthentication && token == null) {
        // Requires authentication
        logger.warning(
            "Not connecting since token is not set and auth is required");
        return;
      }

      await signalR.init(hubUrl, token);

      await lastConnectionInfoSub?.cancel();
      lastConnectionInfoSub = listenOn<Json>(ConnectionEndpoints.connectionInfo)
          .map((json) => ConnectionInfo.fromJson(hubUrl, json))
          .listen((info) {
        _connectionInfo.add(info);
      });

      await signalR.start();
      _onConnectionStarted();
    });
  }

  void _onConnectionStopped() {
    _connectionInfo.add(null);
    _isConnected.add(false);
  }

  void _onConnectionStarted() {
    _isConnected.add(true);
  }

  @override
  Stream<bool> isConnected() {
    return getConnectedState().map((state) => state.isConnected);
  }

  @override
  Stream<ConnectionStateData> getConnectedState() {
    return _connectionState;
  }

  @override
  Future<S> invoke<S>(String endpoint, {List? args}) async {
    var response = await signalR.getConnection()?.invoke(endpoint, args: args);
    assert(response is S, "Invoke expected wrong type");
    return response as S;
  }

  @override
  Stream<S> listenOn<S>(String endpoint) {
    late StreamController<S> controller;

    void callback(List<dynamic>? values) {
      try {
        if (values != null && values.isNotEmpty) {
          controller.add(values[0] as S);
        }
      } catch (error) {
        logger.severe("Callback on listenOn failed: ", error);
        controller.addError(error);
      }
    }

    void startListening() {
      signalR.getConnection()?.on(endpoint, callback);
    }

    void stopListening() {
      signalR.getConnection()?.off(endpoint, method: callback);
    }

    controller = StreamController<S>(
        onListen: startListening,
        onPause: stopListening,
        onResume: startListening,
        onCancel: stopListening);

    return controller.stream;
  }

  @override
  Future stop() async {
    await signalR.stop();
    _isConnected.close();
    _connectionInfo.close();
    _subscription?.cancel();
    _addressTokenSubscription?.cancel();
  }
}
