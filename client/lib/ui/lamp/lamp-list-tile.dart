import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';

class LampListTile extends StatefulWidget {
  late LampState lampState;
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
  late bool isOn;

  LampState(String deviceState) {
    isOn = int.parse(deviceState) > 0;
  }
}

class _LampListTileState extends State<LampListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                enabled: widget.deviceState.connected!,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DeviceIcon(widget.deviceState),
                ),
                trailing: InkWell(
                  onTap: widget.deviceState.connected!
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
                        child: Switch(
                      value: widget.lampState.isOn,
                      onChanged: widget.deviceState.connected!
                          ? (bool value) {
                              setState(() => setSwitchState(connection, value));
                            }
                          : null,
                    )),
                  ],
                ),
              ),
            ));
  }

  void setSwitchState(Connection connection, bool value) {
    connection.sendRequest(
        widget.deviceState.deviceId, "switch", value ? "1.0" : "0.0");
  }
}

class DeviceIcon extends StatelessWidget {
  final DeviceState state;
  DeviceIcon(this.state);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _getIconForType(state.info.type),
      width: 36,
      height: 36,
      color: Colors.white,
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
      default:
        return "assets/icons/unknown.svg";
    }
  }
}
