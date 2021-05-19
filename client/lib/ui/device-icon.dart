import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class DeviceIcon extends StatelessWidget {
  final DeviceState state;
  DeviceIcon(this.state);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _getIconForType(state.info.type),
      width: 36,
      height: 36,
      color: Colors.white.withOpacity(state.connected ? 1 : 0.3),
    );
  }

  String _getIconForType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.Curtain:
        return "assets/icons/curtain.svg";
      case DeviceType.Lamp:
        return "assets/icons/lamp.svg";
      case DeviceType.Switch:
        return "assets/icons/switch.svg";
      case DeviceType.Thermo:
        return "assets/icons/thermo.svg";
      default:
        return "assets/icons/unknown.svg";
    }
  }
}
