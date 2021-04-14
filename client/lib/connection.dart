import 'dart:async';

import 'package:curtains_client/api/api-methods.dart';
import 'package:curtains_client/model/devices-model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:signalr_core/signalr_core.dart';

class Connection extends ChangeNotifier implements ApiMethods {
  HubConnection _connection;
  String _address;

  DevicesModel _devicesModel;

  BehaviorSubject<bool> _isConnected = new BehaviorSubject<bool>();

  Future<void> start(String hubAddress) async {
    _address = hubAddress;

    print("Starting connection");
    _connection = HubConnectionBuilder()
        .withUrl(hubAddress + '/hub')
        .withHubProtocol(JsonHubProtocol())
        .withAutomaticReconnect()
        .build();

    _connection?.onreconnected((connectionId) {
      print("Reconnected");
      _refreshConnectionState();
    });

    _connection?.onclose((error) {
      print("Connection Closed");
      _refreshConnectionState();
    });

    _devicesModel = new DevicesModel(this);

    await _connection?.start();
    _refreshConnectionState();
  }

  void stop() {
    _isConnected.close();
  }

  void _refreshConnectionState() {
    _isConnected.add(isConnected());
    notifyListeners();
  }

  bool isConnected() {
    return _connection?.state == HubConnectionState.connected ?? false;
  }

  Stream<bool> getConnectedState() {
    return _isConnected.stream.distinct();
  }

  String getAddress() {
    return _address;
  }

  void listenOn(String endpoint, Function(List<dynamic>) callback) {
    print("Listening on " + endpoint);
    _connection?.off(endpoint);
    _connection?.on(endpoint, (message) {
      try {
        print("Endpoint: '" +
            endpoint +
            "' - Received: " +
            message[0].toString());
        callback(message[0]);
      } catch (e) {
        print(e);
      }
    });
  }

  DevicesModel getDevicesModel() {
    return _devicesModel;
  }

  @override
  Future setSpeed(String deviceId, double speed) async {
    await _connection?.send(methodName: "SetSpeed", args: [deviceId, speed]);
  }

  @override
  Future setDeviceName(String deviceId, String name) async {
    await _connection
        ?.send(methodName: "ChangeDeviceName", args: [deviceId, name]);
  }
}
