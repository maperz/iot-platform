import 'dart:convert';

import 'package:curtains_client/models/device/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'generic-device-tile.dart';

class DistanseSensorState {
  late double distance;
  // late double change;

  DistanseSensorState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var tempJson = state['distance'] ?? "0.0";
    distance = tempJson is int ? (tempJson).toDouble() : tempJson;
  }
}

class DistanceSensorListTile extends StatelessWidget {
  final DeviceState deviceState;
  late final DistanseSensorState distanceSensorState;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceDetail;

  DistanceSensorListTile(
      {required this.deviceState,
      required this.onClick,
      required this.showDeviceDetail,
      Key? key})
      : super(key: key) {
    this.distanceSensorState = DistanseSensorState(this.deviceState.state);
  }

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        onClick: onClick,
        showDeviceDetail: showDeviceDetail,
        deviceState: deviceState,
        builder: (context) =>
            Text(distanceSensorState.distance.toString() + "cm"));
  }
}
