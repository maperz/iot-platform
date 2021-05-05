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

  Stream<String> getConnectionAddress();

  void listenOn(String endpoint, Function(List<dynamic>) callback);
}

class ConnectionState {
  final bool shouldConnect;
  final String address;
  ConnectionState(this.shouldConnect, this.address);
}

class Connection extends ChangeNotifier implements IConnection {
  HubConnection _connection;

  BehaviorSubject<bool> _isConnected = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _startState = BehaviorSubject.seeded(false);
  BehaviorSubject<String> _addressStream = new BehaviorSubject();

  Connection(AddressResolver addressResolver) {
    addressResolver.getHubUrl().listen((address) {
      _addressStream.add(address);
    });

    var connectionStream = CombineLatestStream.combine2(
        _startState.distinct(),
        _addressStream.distinct(),
        (bool connect, String address) =>
            new ConnectionState(connect, address));

    connectionStream.listen(
        (state) async => _handleConnection(state.shouldConnect, state.address));
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
    return _isConnected.stream.distinct();
  }

  @override
  Stream<String> getConnectionAddress() {
    return _addressStream;
  }

  @override
  void listenOn(String endpoint, Function(List<dynamic>) callback) {
    print("Listening on " + endpoint);
    _connection?.off(endpoint);
    _connection?.on(endpoint, (message) {
      try {
        print('Endpoint: $endpoint - Received: ${message[0].toString()}');
        callback(message[0]);
      } catch (e) {
        print(e);
      }
    });
  }

  // API

  @override
  Future setSpeed(String deviceId, double speed) async {
    await _connection?.send(methodName: "SetSpeed", args: [deviceId, speed]);
  }

  @override
  Future setDeviceName(String deviceId, String name) async {
    await _connection
        ?.send(methodName: "ChangeDeviceName", args: [deviceId, name]);
  }

  @override
  Future getDeviceList() async {
    await _connection?.send(methodName: "GetDeviceList", args: []);
  }

  Future _handleConnection(bool connect, String address) async {
    final isConnected = _isConnected.value;

    if (!connect && isConnected) {
      print("Stopping connection");
      await _connection.stop();
      _connection = null;
      _refreshConnectionState();
    }

    final hubUrl = address + '/hub';

    if (connect && !isConnected) {
      _createConnection(hubUrl);
      print('Starting connection at $hubUrl');
      await _connection?.start();
      _refreshConnectionState();
    }

    if (connect && isConnected && _connection.baseUrl != hubUrl) {
      _createConnection(address);
      print("Reconnecting to different url");
      await _connection.stop();
      _connection = null;
      _refreshConnectionState();
      await _connection?.start();
      _refreshConnectionState();
    }
  }

  void _createConnection(String hubUrl) {
    _connection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withHubProtocol(JsonHubProtocol())
        .withAutomaticReconnect()
        .build();

    _connection.onreconnected((connectionId) {
      print("Reconnected");
      _refreshConnectionState();
    });

    _connection.onclose((error) {
      print("Connection Closed");
      _refreshConnectionState();
    });
  }

  void _refreshConnectionState() {
    final isConnected =
        _connection?.state == HubConnectionState.connected ?? false;

    _isConnected.add(isConnected);
    notifyListeners();
  }
}
