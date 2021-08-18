import 'dart:convert';

import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/home/components/helper/last-update-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../device-icon.dart';

typedef RequestMeasurementCallback = Function();
typedef ShowDeviceDetailCallback = Function();

class DistanseSensorState {
  late double distance;
  // late double change;

  DistanseSensorState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var tempJson = state['distance'] ?? "0.0";
    distance = tempJson is int ? (tempJson).toDouble() : tempJson;
  }
}

class DistanceSensorTile extends StatelessWidget {
  final DeviceState deviceState;
  late final DistanseSensorState distanceSensorState;

  final RequestMeasurementCallback requestCallback;
  final ShowDeviceDetailCallback showDeviceDetail;
  DistanceSensorTile(
      {required this.deviceState,
      required this.requestCallback,
      required this.showDeviceDetail,
      Key? key})
      : super(key: key) {
    this.distanceSensorState = DistanseSensorState(this.deviceState.state);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => requestCallback(),
        child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            enabled: deviceState.connected,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DeviceIcon(deviceState),
            ),
            trailing: InkWell(
              onTap: deviceState.connected ? showDeviceDetail : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(deviceState.getDisplayName()),
                Container(
                  width: 10,
                ),
                Text(distanceSensorState.distance.toString() + "cm"),
              ],
            ),
            subtitle: LastUpdateText(deviceState.lastUpdate)),
      ),
    );
  }
}
