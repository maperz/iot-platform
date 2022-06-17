import 'package:iot_client/models/device/index.dart';
import 'package:flutter/material.dart';

class DeviceIcon extends StatelessWidget {
  final DeviceState state;
  const DeviceIcon(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final asset = _getIconForType(state.info.type);
    const width = 36.0;
    final color = Colors.white.withOpacity(state.connected ? 1 : 0.3);

    return Image.asset("assets/icons/$asset", width: width, color: color);
  }

  String _getIconForType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.curtain:
        return "curtain.png";
      case DeviceType.lamp:
        return "lamp.png";
      case DeviceType.switcher:
        return "switch.png";
      case DeviceType.thermometer:
        return "thermo.png";
      case DeviceType.distanceSensor:
        return "distance-sensor.png";
      case DeviceType.airqualitySensor:
        return "airquality.png";
      default:
        return "unknown-device.png";
    }
  }
}
