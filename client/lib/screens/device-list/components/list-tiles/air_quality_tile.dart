import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/airquality_state.dart';
import 'package:iot_client/models/device/models/domain-states/distance_sensor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helper/generic_device_tile.dart';

class AirQualityTile extends StatelessWidget {
  final DeviceInfo deviceInfo;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceSettings;

  const AirQualityTile(
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
          var qualityState = AirQualityState.fromJson(deviceState.state);
          return Text(qualityState.quality.toString() +
              " ppm, " +
              qualityState.temp.toString() +
              "°C");
        });
  }
}
