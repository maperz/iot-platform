import 'package:curtains_client/models/device/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DeviceIcon extends StatelessWidget {
  final DeviceState state;
  DeviceIcon(this.state);

  @override
  Widget build(BuildContext context) {
    final asset = _getIconForType(state.info.type);
    final width = 36.0;
    final color = Colors.white.withOpacity(state.connected ? 1 : 0.3);

    return Image.asset("assets/icons/$asset", width: width, color: color);
  }

  String _getIconForType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.Curtain:
        return "curtain.png";
      case DeviceType.Lamp:
        return "lamp.png";
      case DeviceType.Switch:
        return "switch.png";
      case DeviceType.Thermo:
        return "thermo.png";
      case DeviceType.DistanceSensor:
        return "distance-sensor.png";
      default:
        return "unknown-device.png";
    }
  }
}
