import 'package:equatable/equatable.dart';

import 'device-info.dart';
import 'device-type.dart';

class DeviceState extends Equatable {
  final String deviceId;
  final DeviceInfo info;

  final bool connected;
  final String state;
  final DateTime lastUpdate;

  const DeviceState(
      this.deviceId, this.connected, this.state, this.info, this.lastUpdate);

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    var state = json['state'];
    var name = json['info']['name'];
    var type = parseDeviceType(json['info']['type']);
    var version = json['info']['version'] ?? "";
    var lastUpdate = DateTime.parse(json['lastUpdate']);

    return DeviceState(json['deviceId'], json['connected'], state,
        DeviceInfo(json['deviceId'], name, type, version), lastUpdate);
  }

  String getDisplayName() {
    return info.getDisplayName();
  }

  @override
  String toString() {
    return "[$deviceId-${info.type}]: Connected: $connected, $lastUpdate, $state";
  }

  @override
  List<Object> get props => [deviceId, info, connected, state, lastUpdate];
}
