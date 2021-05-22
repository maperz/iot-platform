import 'dart:async';

import 'package:curtains_client/api/api-methods.dart';
import 'package:curtains_client/connection/address-resolver.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:signalr_core/signalr_core.dart';

abstract class IConnection implements ApiMethods {
  void start();

  void stop();

  Stream<bool> getConnectedState();

  Stream<String?> getConnectionAddress();

  void listenOn(String endpoint, Function(List<dynamic>?) callback);
}

class ConnectionInfo {
  bool isConnected;
  bool isProxy;
  String? proxiedAddress;
  String version;

  ConnectionInfo(
      this.isConnected, this.isProxy, this.proxiedAddress, this.version);

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) {
    var isConnected = json['isConnected'];
    var isProxy = json['isProxy'];
    var proxiedAddress = json['proxiedAddress'];
    var version = json['version'];

    return ConnectionInfo(isConnected, isProxy, proxiedAddress, version);
  }
}

class ConnectionState {
  final bool shouldConnect;
  final String? address;
  final Exception? connectionError;

  ConnectionState(this.shouldConnect, this.address, this.connectionError);
}

class Connection extends ChangeNotifier implements IConnection {
  HubConnection? _connection;

  late Stream<bool> _isConnected;
  BehaviorSubject<bool> _startState = BehaviorSubject.seeded(false);
  BehaviorSubject<Exception?> _connectionError = BehaviorSubject.seeded(null);
  BehaviorSubject<ConnectionInfo?> _connectionInfo =
      BehaviorSubject.seeded(null);

  BehaviorSubject<String?> _addressStream = new BehaviorSubject();

  Connection(IAddressResolver addressResolver) {
    addressResolver.getHubUrl().listen((address) {
      _addressStream.add(address);
    });

    var connectionStream = CombineLatestStream.combine3(
        _startState.distinct(),
        _addressStream.distinct(),
        _connectionError,
        (bool connect, String? address, Exception? error) =>
            new ConnectionState(connect, address, error));

    _isConnected = _connectionInfo
        .map((info) => info != null && info.isConnected)
        .distinct();

    connectionStream.listen((state) async => _handleConnection(
        state.shouldConnect, state.address, state.connectionError));

    _isConnected.listen((event) {
      notifyListeners();
    });
  }
  @override
  void start() {
    _startState.sink.add(true);
  }

  @override
  void stop() {
    _startState.sink.add(false);
  }

  @override
  Stream<bool> getConnectedState() {
    return _isConnected;
  }

  Stream<ConnectionInfo?> getConnectionInfo() {
    return _connectionInfo.stream.distinct();
  }

  @override
  Stream<String?> getConnectionAddress() {
    return _addressStream;
  }

  @override
  void listenOn(String endpoint, Function(List<dynamic>?) callback) {
    print("Listening on " + endpoint);
    _connection?.off(endpoint);
    _connection?.on(endpoint, (message) {
      try {
        print('Endpoint: $endpoint - Received: ${message![0].toString()}');
        callback(message[0]);
      } catch (e) {
        print(e);
      }
    });
  }

  // API

  @override
  Future sendRequest(String deviceId, String name, String payload) async {
    await _connection?.invoke("SendRequest", args: [deviceId, name, payload]);
  }

  @override
  Future setDeviceName(String deviceId, String name) async {
    await _connection?.invoke("ChangeDeviceName", args: [deviceId, name]);
  }

  @override
  Future<Iterable<dynamic>> getDeviceList() async {
    var deviceList =
        (await _connection?.invoke("GetDeviceList")) as Iterable<dynamic>;
    return deviceList;
  }

  Future _handleConnection(
      bool connect, String? address, Exception? connectionError) async {
    final isConnected = _connection?.state == HubConnectionState.connected;

    if ((!connect || address == null) && isConnected) {
      print("Stopping connection");
      await _connection!.stop();
      _connection = null;
      _connectionInfo.add(null);
      return;
    }

    if (!connect || address == null) {
      return;
    }

    final hubUrl = address + '/hub';

    if (connect && !isConnected) {
      _createConnection(hubUrl);
      print('Starting connection at $hubUrl');
      await _connection?.start();
      return;
    }

    if (connect && _connection!.baseUrl != hubUrl) {
      _createConnection(address);
      print("Reconnecting to different url");
      stop();
      start();
    }
  }

  void _createConnection(String hubUrl) {
    final options = new HttpConnectionOptions(
      // Workaround to fix a bug that currently happens when connecting
      // to the server
      transport: hubUrl.contains("iot.perz.cloud")
          ? HttpTransportType.serverSentEvents
          : HttpTransportType.webSockets,
      //logging: (level, message) => print(message)
    );

    _connection = HubConnectionBuilder()
        .withUrl(hubUrl, options)
        .withHubProtocol(JsonHubProtocol())
        .withAutomaticReconnect()
        .build();

    _connection!.onreconnected((connectionId) {
      print("Reconnected");
      _connectionInfo.add(null);
    });

    _connection!.onclose((error) {
      print("Connection Closed");
      _connectionError.add(error);
      _connectionInfo.add(null);
    });

    _connection!.on("ConnectionInfo", (message) {
      if (message != null && message.length > 0) {
        var info = ConnectionInfo.fromJson(message[0]);
        _connectionInfo.add(info);
      }
    });
  }
}
