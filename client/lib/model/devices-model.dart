import 'package:curtains_client/connection.dart';
import 'package:flutter/foundation.dart';

import '../endpoints.dart';

enum DeviceType { Curtain }

class DeviceState {
  final String deviceId;
  final String name;
  final DeviceType type;
  final bool connected;
  final double speed;

  DeviceState(this.deviceId, this.connected, this.speed, this.name, this.type);

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException("Null JSON provided to DeviceState");
    }

    var speedJson = json['speed'];
    var speed = speedJson is int ? (speedJson).toDouble() : speedJson;

    // TODO:
    String name;
    var type = DeviceType.Curtain;

    return DeviceState(json['deviceId'], json['connected'], speed, name, type);
  }

  getTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.Curtain:
        return "Curtain";
      default:
        return 'Device';
    }
  }

  getDisplayName() {
    return name ?? getTypeName(type);
  }
}

class DevicesModel extends ChangeNotifier {
  final Connection _connection;
  final Map<String, DeviceState> _states = new Map();

  DevicesModel(this._connection) {
    _connection.listenOn(Endpoints.DeviceStateChangedEndpoint, (updateList) {
      var states = updateList.map((json) => DeviceState.fromJson(json));
      _updateStates(states);
    });
  }

  void _updateStates(Iterable<DeviceState> states) {
    for (var state in states) {
      _states[state.deviceId] = state;
    }
    notifyListeners();
  }

  List<DeviceState> getDeviceStates() {
    return _states.values.toList();
  }
}
