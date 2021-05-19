import 'dart:convert';

import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';
import '../device-icon.dart';

class CurtainListTile extends StatefulWidget {
  final DeviceState deviceState;
  late CurtainState curtainState;

  CurtainListTile(
    this.deviceState, {
    Key? key,
  }) : super(key: key) {
    this.curtainState = CurtainState(this.deviceState.state);
  }

  @override
  _CurtainListTileState createState() => _CurtainListTileState();
}

class CurtainState {
  /* Example curtain state
   * {
   *  speed: "1.0",
   * }
   */

  late double progress;

  CurtainState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var speedJson = state['speed'];
    progress = speedJson is int ? (speedJson).toDouble() : speedJson;
  }
}

class _CurtainListTileState extends State<CurtainListTile> {
  double _currentSliderValue = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
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
                    Expanded(
                      child: Slider(
                        value: _currentSliderValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 40,
                        label: (_currentSliderValue * 100).round().toString() +
                            " Percent",
                        onChanged: widget.deviceState.connected
                            ? (double value) {
                                setState(() => setSpeed(connection, value));
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  void setSpeed(Connection connection, double value) {
    _currentSliderValue = value;
    connection.sendRequest(
        widget.deviceState.deviceId, "speed", value.toStringAsPrecision(2));
  }
}
