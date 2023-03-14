import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/services/device/device_state_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../models/device/models/domain-states/blind_state.dart';
import '../../../../services/api/api_service.dart';
import 'helper/generic_device_tile.dart';

enum BlindPosition { top, mid, bot }

class BlindListTile extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final IDeviceStateService deviceStateService;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceSettings;

  const BlindListTile(
      {required this.deviceInfo,
      required this.onClick,
      required this.deviceStateService,
      required this.showDeviceSettings,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => GenericDeviceTile(
            onClick: onClick,
            showDeviceSettings: showDeviceSettings,
            deviceInfo: deviceInfo,
            builder: (context, deviceState) {
              var blindState = BlindState.fromJson(deviceState.state);
              return Row(children: [
                Text(""),
              ]);
            },
            detailBuilder: (context, deviceState) {
              return Column(children: [
                IconButton(
                    onPressed: () => _sendBlindMoveCommand(
                        apiService, BlindPosition.top, deviceState),
                    icon: const Icon(Icons.north)),
                IconButton(
                    onPressed: () => _sendBlindMoveCommand(
                        apiService, BlindPosition.mid, deviceState),
                    icon: const Icon(Icons.star)),
                IconButton(
                    onPressed: () => _sendBlindMoveCommand(
                        apiService, BlindPosition.bot, deviceState),
                    icon: const Icon(Icons.south))
              ]);
            }));
  }

  void _sendBlindMoveCommand(
      IApiService apiService, BlindPosition position, DeviceState deviceState) {
    apiService.sendRequest(deviceState.deviceId, "move", position.name);
  }
}
