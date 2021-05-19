import 'package:curtains_client/domain/device/devices-model.dart';
import 'package:curtains_client/ui/curtain/curtain-list-tile.dart';
import 'package:curtains_client/ui/lamp/lamp-list-tile.dart';
import 'package:curtains_client/ui/thermo/thermo-list-tile.dart';
import 'package:curtains_client/ui/unknown-list-tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/device/device-state.dart';

class DeviceListWidget extends StatefulWidget {
  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceListModel>(
        builder: (context, devices, child) => ListView.builder(
              itemCount: devices.getDeviceStates().length,
              itemBuilder: (context, index) {
                final deviceState = devices.getDeviceStates()[index];
                final type = deviceState.info.type;

                switch (type) {
                  case DeviceType.Curtain:
                    return CurtainListTile(deviceState);
                  case DeviceType.Lamp:
                    return LampListTile(deviceState);
                  case DeviceType.Thermo:
                    return ThermoListTile(deviceState);
                  default:
                    return UnknownListTile(deviceState);
                }
              },
            ));
  }
}
