import 'dart:convert';

import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';
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
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
              child: InkWell(
                onTap: () => requestMeasurement(connection),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  enabled: widget.deviceState.connected,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DeviceIcon(widget.deviceState),
                  ),
                  trailing: InkWell(
                    onTap: widget.deviceState.connected
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailDevicePage(
                                        widget.deviceState, connection)));
                          }
                        : null,
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
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.thermoState.temp.toString() + "°C"),
                              Container(
                                width: 10,
                              ),
                              Text(widget.thermoState.hum.toString() + "%"),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  subtitle: Text(
                    DateFormat("H:mm:ss d.M.y")
                        .format(widget.deviceState.lastUpdate.toLocal()),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ));
  }

  void requestMeasurement(Connection connection) {
    connection.sendRequest(widget.deviceState.deviceId, "temperature", "");
  }
}
