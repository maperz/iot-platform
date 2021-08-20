import 'device-type.dart';

class DeviceInfo {
  final String? name;
  final String version;
  final DeviceType type;
  DeviceInfo(this.name, this.type, this.version);
}
