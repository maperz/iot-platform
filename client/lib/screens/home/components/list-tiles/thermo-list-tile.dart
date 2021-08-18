import 'dart:convert';

import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/home/components/helper/last-update-text.dart';
import 'package:curtains_client/services/api/api-service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../device-icon.dart';

class ThermoListTile extends StatefulWidget {
  final DeviceState deviceState;
  late final ThermoState thermoState;

  ThermoListTile(
    this.deviceState, {
    Key? key,
  }) : super(key: key) {
    this.thermoState = ThermoState(this.deviceState.state);
  }

  @override
  _ThermoListTileState createState() => _ThermoListTileState();
}

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

class _ThermoListTileState extends State<ThermoListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => Card(
              child: InkWell(
                onTap: () => requestMeasurement(apiService),
                child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    enabled: widget.deviceState.connected,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DeviceIcon(widget.deviceState),
                    ),
                    trailing: InkWell(
                      onTap: widget.deviceState.connected ? () {} : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert_rounded,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(widget.deviceState.getDisplayName()),
                        Container(
                          width: 10,
                        ),
                        Text(widget.thermoState.temp.toString() + "°C"),
                        Container(
                          width: 10,
                        ),
                        Text(widget.thermoState.hum.toString() + "%"),
                      ],
                    ),
                    subtitle: LastUpdateText(widget.deviceState.lastUpdate)),
              ),
            ));
  }

  void requestMeasurement(IApiService apiService) {
    apiService.sendRequest(widget.deviceState.deviceId, "temperature", "");
  }
}
