import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';

class LampListTile extends StatefulWidget {
  const LampListTile(
    this._deviceState, {
    Key? key,
  }) : super(key: key);

  final DeviceState _deviceState;

  @override
  _LampListTileState createState() => _LampListTileState();
}

class _LampListTileState extends State<LampListTile> {
  _LampListTileState();

  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                enabled: widget._deviceState.connected!,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DeviceIcon(widget._deviceState),
                ),
                trailing: InkWell(
                  onTap: widget._deviceState.connected!
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailDevicePage(
                                      widget._deviceState, connection)));
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
                    Text(widget._deviceState.getDisplayName()),
                    Expanded(
                        child: Switch(
                      value: (widget._deviceState.speed ?? 0) > 0,
                      onChanged: widget._deviceState.connected!
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
        widget._deviceState.deviceId, "switch", value ? "1.0" : "0.0");
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
