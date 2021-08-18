import 'dart:convert';

import 'package:curtains_client/models/device/index.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'generic-device-tile.dart';

class ThermoState {
  /* Example curtain state
   * {
   *  temp: "1.0",
   *  hum: "32.0",
   * }
   */

  late double temp;
  late double hum;

  ThermoState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var tempJson = state['temp'] ?? "0.0";
    var humJson = state['hum'] ?? "0.0";

    temp = tempJson is int ? (tempJson).toDouble() : tempJson;
    hum = humJson is int ? (humJson).toDouble() : humJson;
  }
}

class ThermoListTile extends StatelessWidget {
  final DeviceState deviceState;
  late final ThermoState thermoState;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceDetail;

  ThermoListTile(
      {required this.deviceState,
      required this.onClick,
      required this.showDeviceDetail,
      Key? key})
      : super(key: key) {
    this.thermoState = ThermoState(this.deviceState.state);
  }

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        onClick: onClick,
        showDeviceDetail: showDeviceDetail,
        deviceState: deviceState,
        builder: (context) => Row(
              children: [
                Text(thermoState.temp.toString() + "°C"),
                Container(
                  width: 10,
                ),
                Text(thermoState.hum.toString() + "%")
              ],
            ));
  }
}
