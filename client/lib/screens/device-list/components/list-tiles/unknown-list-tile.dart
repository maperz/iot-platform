import 'package:curtains_client/models/device/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'generic-device-tile.dart';

class UnknownListTile extends StatelessWidget {
  final DeviceState deviceState;

  UnknownListTile(this.deviceState);

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        deviceState: deviceState, builder: (context) => Text("(Unknown Type)"));
  }
}