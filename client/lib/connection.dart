import 'package:curtains_client/api/api-methods.dart';
import 'package:curtains_client/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

class Connection extends ChangeNotifier implements ApiMethods {
  HubConnection _connection;

  Future<void> start(String hubAddress) async {
    print("Starting connection");
    _connection = HubConnectionBuilder()
        .withUrl(hubAddress + '/hub')
        .withAutomaticReconnect()
        .build();

    _connection?.onreconnected((connectionId) {
      print("Reconnected");
      notifyListeners();
    });

    _connection?.onclose((error) {
      print("Connection Closed");
      notifyListeners();
    });

    setupListeners();

    await _connection?.start();
    notifyListeners();
  }

  bool isConnected() {
    return _connection?.state == HubConnectionState.connected ?? false;
  }

  void setupListeners() {
    _connection?.on(Endpoints.DeviceStateChangedEndpoint, (message) {
      print("Received message: " + message.toString());
    });
  }

  @override
  Future setSpeed(double speed) async {
    if (_connection == null) {
      return;
    }
    await _connection?.send(methodName: "SetSpeed", args: [speed]);
  }
}
