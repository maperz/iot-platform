import 'package:equatable/equatable.dart';

import 'device_type.dart';

class DeviceInfo extends Equatable {
  final String id;
  final String? name;
  final String version;
  final DeviceType type;
  const DeviceInfo(this.id, this.name, this.type, this.version);

  @override
  List<Object?> get props => [id, name, version, type];

  String getDisplayName() {
    return name ?? type.getName();
  }
}
