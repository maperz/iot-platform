import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/services/device/device-state-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'helper/generic-device-tile.dart';

class UnknownListTile extends StatelessWidget {
  final DeviceInfo deviceInfo;

  UnknownListTile(this.deviceInfo);

  @override
  Widget build(BuildContext context) {
    return Consumer<IDeviceStateService>(
        builder: (context, deviceStateService, child) => GenericDeviceTile(
            deviceInfo: deviceInfo,
            builder: (context, deviceState) => Text("(Unknown Type)")));
  }
}
