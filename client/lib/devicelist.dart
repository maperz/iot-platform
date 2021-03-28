import 'package:curtains_client/devices-model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'connection.dart';

class DeviceListWidget extends StatefulWidget {
  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DevicesModel>(
        builder: (context, devices, child) => ListView.builder(
              itemCount: devices.getDeviceStates().length,
              itemBuilder: (context, index) {
                return DeviceListTile(devices.getDeviceStates()[index]);
              },
            ));
  }
}

class DeviceListTile extends StatefulWidget {
  const DeviceListTile(
    this._deviceState, {
    Key key,
  }) : super(key: key);

  final DeviceState _deviceState;

  @override
  _DeviceListTileState createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> {
  double _currentSliderValue = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
              child: ListTile(
                enabled: widget._deviceState.connected,
                leading: Icon(
                  Icons.sensor_window_rounded,
                  size: 48,
                ),
                title: Row(
                  children: [
                    Text(widget._deviceState.deviceId),
                    Expanded(
                      child: Slider(
                        value: _currentSliderValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 40,
                        label: (_currentSliderValue * 100).round().toString() +
                            " Percent",
                        onChanged: widget._deviceState.connected
                            ? (double value) {
                                setState(() {
                                  _currentSliderValue = value;
                                  connection.setSpeed(_currentSliderValue);
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
