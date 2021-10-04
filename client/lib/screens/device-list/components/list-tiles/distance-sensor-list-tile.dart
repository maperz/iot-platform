import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/distance-sensor-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helper/generic-device-tile.dart';

class DistanceSensorListTile extends StatelessWidget {
  final DeviceInfo deviceInfo;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceSettings;

  const DistanceSensorListTile(
      {required this.deviceInfo,
      required this.onClick,
      required this.showDeviceSettings,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        onClick: onClick,
        showDeviceSettings: showDeviceSettings,
        deviceInfo: deviceInfo,
        builder: (context, deviceState) {
          var distanceSensorState =
              DistanseSensorState.fromJson(deviceState.state);
          return Text(distanceSensorState.distance.toString() + "cm");
        });
  }
}
