import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/services/device/device_state_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'helper/generic_device_tile.dart';

class UnknownListTile extends StatelessWidget {
  final DeviceInfo deviceInfo;

  const UnknownListTile(this.deviceInfo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IDeviceStateService>(
        builder: (context, deviceStateService, child) => GenericDeviceTile(
            deviceInfo: deviceInfo,
            builder: (context, deviceState) => const Text("(Unknown Type)")));
  }
}
