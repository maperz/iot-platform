import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:curtains_client/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../device-detail.dart';
import '../device-icon.dart';

class LampListTile extends StatefulWidget {
  late final LampState lampState;
  final DeviceState deviceState;

  LampListTile(
    this.deviceState, {
    Key? key,
  }) : super(key: key) {
    this.lampState = LampState(this.deviceState.state);
  }

  @override
  _LampListTileState createState() => _LampListTileState();
}

class LampState {
  /* Example lamp state
   * {
   *  isOn: true/false,
   *  color: "#000000"
   * }
   */

  late bool isOn;
  late Color color;

  LampState(String jsonEncode) {
    final state = json.decode(jsonEncode);
    isOn = state["isOn"];
    color = hexToColor(state["color"]);
  }
}

class _LampListTileState extends State<LampListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                decoration: BoxDecoration(
                    color: widget.lampState.color.withOpacity(
                        (widget.deviceState.connected && widget.lampState.isOn)
                            ? 1
                            : 0),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: InkWell(
                  onTap: () => setState(
                      () => setSwitchState(connection, !widget.lampState.isOn)),
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
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  void setSwitchState(Connection connection, bool value) {
    connection.sendRequest(
        widget.deviceState.deviceId, "switch", value ? "1.0" : "0.0");
  }
}
