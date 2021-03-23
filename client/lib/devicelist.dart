import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'connection.dart';

class DeviceListWidget extends StatefulWidget {
  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.sensor_window_rounded,
                      size: 48,
                    ),
                    title: Slider(
                      value: _currentSliderValue,
                      min: -1.0,
                      max: 1.0,
                      divisions: 40,
                      label: (_currentSliderValue * 100).round().toString() +
                          " Percent",
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                          connection.setSpeed(_currentSliderValue);
                        });
                      },
                    ),
                  ),
                );
              },
            ));
  }
}
