enum DeviceType { Unknown, Curtain, Lamp, Switch }

class DeviceInfo {
  final String? name;
  final String version;
  final DeviceType type;
  DeviceInfo(this.name, this.type, this.version);
}

class DeviceState {
  final String? deviceId;
  final DeviceInfo info;

  final bool? connected;
  final double? speed;

  DeviceState(this.deviceId, this.connected, this.speed, this.info);

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    var speedJson = json['speed'];
    var speed = speedJson is int ? (speedJson).toDouble() : speedJson;

    var name = json['info']['name'];
    var type = _parseType(json['info']['type']);
    var version = json['info']['version'] ?? "";

    return DeviceState(json['deviceId'], json['connected'], speed,
        new DeviceInfo(name, type, version));
  }

  String getDisplayName() {
    return this.info.name ?? _getTypeName(this.info.type);
  }

  static DeviceType _parseType(String type) {
    switch (type.toLowerCase().trim()) {
      case "curtain":
        return DeviceType.Curtain;
      case "lamp":
        return DeviceType.Lamp;
      case "switch":
        return DeviceType.Switch;
      default:
        return DeviceType.Unknown;
    }
  }

  String _getTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.Curtain:
        return "Curtain";
      case DeviceType.Lamp:
        return "Lamp";
      case DeviceType.Switch:
        return "Switch";
      default:
        return 'Unknown';
    }
  }
}
