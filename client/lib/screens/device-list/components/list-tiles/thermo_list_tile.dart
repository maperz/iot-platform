import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/thermo_state.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/details/thermo_detail_page.dart';
import 'package:iot_client/services/device/device_state_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helper/generic_device_tile.dart';

class ThermoListTile extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final IDeviceStateService deviceStateService;

  final OnDeviceClickedCallback onClick;
  final ShowDeviceDetailCallback showDeviceSettings;

  const ThermoListTile(
      {required this.deviceInfo,
      required this.onClick,
      required this.deviceStateService,
      required this.showDeviceSettings,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenericDeviceTile(
        onClick: onClick,
        showDeviceSettings: showDeviceSettings,
        deviceInfo: deviceInfo,
        builder: (context, deviceState) {
          var thermoState = ThermoState.fromJson(deviceState.state);
          return Row(
            children: [
              Text(thermoState.temp.toString() + "°C"),
              Container(
                width: 10,
              ),
              Text(thermoState.hum.toString() + "%")
            ],
          );
        },
        detailBuilder: (context, deviceState) {
          final lastWeekAgo =
              DateTime.now().toUtc().subtract(const Duration(days: 7));
          return FutureBuilder<Iterable<DeviceState>>(
              future: deviceStateService.getStateHistory(deviceState.deviceId,
                  intervalSeconds: const Duration(hours: 4).inSeconds,
                  start: lastWeekAgo,
                  type: DeviceType.thermometer),
              builder: (context, stateHistorySnapshot) {
                if (stateHistorySnapshot.hasError) {
                  return const Text(
                      "An error occured while gettint the state history");
                }

                if (stateHistorySnapshot.hasData &&
                    stateHistorySnapshot.data != null) {
                  var stateHistory = stateHistorySnapshot.data!;

                  return AspectRatio(
                    aspectRatio: 2.5,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: ThermoDetailPage.fromDeviceHistory(stateHistory),
                      ),
                    ),
                  );
                }
                return Container();
              });
        });
  }
}
