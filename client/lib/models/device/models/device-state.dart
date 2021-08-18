import 'device-info.dart';
import 'device-type.dart';

class DeviceState {
  final String deviceId;
  final DeviceInfo info;

  final bool connected;
  final String state;
  final DateTime lastUpdate;

  DeviceState(
      this.deviceId, this.connected, this.state, this.info, this.lastUpdate);

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    var state = json['state'];
    var name = json['info']['name'];
    var type = parseDeviceType(json['info']['type']);
    var version = json['info']['version'] ?? "";
    var lastUpdate = DateTime.parse(json['lastUpdate']);

    return DeviceState(json['deviceId'], json['connected'], state,
        new DeviceInfo(name, type, version), lastUpdate);
  }

  String getDisplayName() {
    return this.info.name ?? this.info.type.getName();
  }
}
