import 'dart:async';

import 'package:iot_client/models/connection/index.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:iot_client/services/auth/auth-service.dart';
import 'package:iot_client/services/connection/address-resolver.dart';
import 'package:iot_client/services/connection/signalr/signalr-helper.dart';
import 'package:iot_client/models/connection/models/hub-address.dart';

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
  static const String ConnectionInfo = "ConnectionInfo";
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

  late final BehaviorSubject<ConnectionStateData> _connectionState =
      BehaviorSubject.seeded(ConnectionStateData.disconnected);

  final BehaviorSubject<bool> _isConnected = BehaviorSubject.seeded(false);

  final BehaviorSubject<ConnectionInfo?> _connectionInfo =
      BehaviorSubject.seeded(null);

  ConnectionService({required this.addressResolver, required this.authService});

  @override
  Future start() async {
    void onReconnecting(Exception? err) {}

    void onReconnected(String? id) {}

    signalR = SignalRHelper(
        onReconnect: onReconnecting, onReconnected: onReconnected);

    Rx.combineLatest2(
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

    var changeStream = Rx.combineLatest2(
        addressChanged,
        tokenChanged,
        (HubAddress address, String? token) =>
            AddressTokenTuple(address, token)).distinct();

    await for (var change in changeStream) {
      var address = change.address;
      var token = change.token;

      final hubUrl = address.toString() + '/hub';

      logger.fine(
          "Handle connection to $hubUrl. Requires Auth: ${address.requiresAuthentication} and Token: ${token?.substring(0, 5)}...");

      await signalR.stop();
      _onConnectionStopped();

      if (address.requiresAuthentication && token == null) {
        // Requires authentication
        logger.warning(
            "Not connecting since token is not set and auth is required");
        continue;
      }

      await signalR.init(hubUrl, token);

      listenOn<Json>(ConnectionEndpoints.ConnectionInfo)
          .map((json) => ConnectionInfo.fromJson(hubUrl, json))
          .listen((info) {
        _connectionInfo.add(info);
      });

      await signalR.start();
      _onConnectionStarted(hubUrl);
    }
  }

  void _onConnectionStopped() {
    _connectionInfo.add(null);
    _isConnected.add(false);
  }

  void _onConnectionStarted(String hubUrl) {
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
    // ignore: close_sinks
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
  }
}
