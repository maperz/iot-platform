import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';

class CurtainListTile extends StatefulWidget {
  const CurtainListTile(
    this._deviceState, {
    Key? key,
  }) : super(key: key);

  final DeviceState _deviceState;

  @override
  _CurtainListTileState createState() => _CurtainListTileState();
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
                      child: Slider(
                        value: _currentSliderValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 40,
                        label: (_currentSliderValue * 100).round().toString() +
                            " Percent",
                        onChanged: widget._deviceState.connected!
                            ? (double value) {
                                setState(() {
                                  _currentSliderValue = value;
                                  connection.setSpeed(
                                      widget._deviceState.deviceId,
                                      _currentSliderValue);
                                });
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ));
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
      default:
        return "assets/icons/lamp.svg";
    }
  }
}
