import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/models/device/models/domain-states/thermo-state.dart';
import 'package:curtains_client/screens/device-list/components/list-tiles/details/thermo-detail-page.dart';
import 'package:curtains_client/services/device/device-state-service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helper/generic-device-tile.dart';

class ThermoListTile extends StatelessWidget {
  final DeviceState deviceState;
  late final ThermoState thermoState;
  final IDeviceStateService deviceStateService;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceSettings;

  ThermoListTile(
      {required this.deviceState,
      required this.onClick,
      required this.deviceStateService,
      required this.showDeviceSettings,
      Key? key})
      : super(key: key) {
    this.thermoState = ThermoState.fromJson(this.deviceState.state);
  }

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        onClick: onClick,
        showDeviceSettings: showDeviceSettings,
        deviceState: deviceState,
        builder: (context) => Row(
              children: [
                Text(thermoState.temp.toString() + "°C"),
                Container(
                  width: 10,
                ),
                Text(thermoState.hum.toString() + "%")
              ],
            ),
        detailBuilder: (context) => FutureBuilder<Iterable<DeviceState>>(
            future: deviceStateService.getStateHistory(deviceState.deviceId,
                intervalSeconds: Duration(hours: 1).inSeconds, count: 100),
            builder: (context, stateHistorySnapshot) {
              if (stateHistorySnapshot.hasData) {
                return AspectRatio(
                  aspectRatio: 2.5,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ThermoDetailPage.fromDeviceHistory(
                          stateHistorySnapshot.data!),
                    ),
                  ),
                );
              }
              return Container();
            }));
  }
}
