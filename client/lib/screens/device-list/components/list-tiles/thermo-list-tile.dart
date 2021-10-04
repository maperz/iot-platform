import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/thermo-state.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/details/thermo-detail-page.dart';
import 'package:iot_client/services/device/device-state-service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'helper/generic-device-tile.dart';

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
              DateTime.now().toUtc().subtract(Duration(days: 7));
          return FutureBuilder<Iterable<DeviceState>>(
              future: deviceStateService.getStateHistory(deviceState.deviceId,
                  intervalSeconds: Duration(hours: 4).inSeconds,
                  start: lastWeekAgo,
                  type: DeviceType.Thermo),
              builder: (context, stateHistorySnapshot) {
                if (stateHistorySnapshot.hasError) {
                  return Text(
                      "An error occured while gettint the state history");
                }

                if (stateHistorySnapshot.hasData &&
                    stateHistorySnapshot.data != null) {
                  var stateHistory = stateHistorySnapshot.data!;

                  return AspectRatio(
                    aspectRatio: 2.5,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 200),
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
