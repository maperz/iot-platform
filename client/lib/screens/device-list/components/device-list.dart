import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/device-settings/device-settings-page.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:curtains_client/services/connection/connection.dart';
import 'package:curtains_client/services/device/device-state-service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './list-tiles/index.dart';

class DeviceListWidget extends StatefulWidget {
  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<IConnectionService, IApiService>(
      builder: (context, connectionService, apiService, child) {
        IDeviceStateService deviceStateService = new DeviceListService(
            connectionService: connectionService, apiService: apiService);

        return StreamBuilder<DeviceStateList>(
            stream: deviceStateService.getDeviceStates(),
            builder: (context, deviceStatesSnapshot) {
              if (deviceStatesSnapshot.data == null) {
                return Container();
              }

              final devices = deviceStatesSnapshot.data!;

              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final deviceState = devices.elementAt(index);
                  final type = deviceState.info.type;

                  switch (type) {
                    case DeviceType.Curtain:
                      return CurtainListTile(deviceState);
                    case DeviceType.Lamp:
                      return LampListTile(
                        deviceState,
                        showDeviceSettings: () =>
                            _showDeviceSettingsPage(deviceState, apiService),
                      );
                    case DeviceType.Thermo:
                      return ThermoListTile(
                          deviceStateService: deviceStateService,
                          deviceState: deviceState,
                          onClick: () => apiService.sendRequest(
                              deviceState.deviceId, "temperature", ""),
                          showDeviceSettings: () =>
                              _showDeviceSettingsPage(deviceState, apiService));
                    case DeviceType.DistanceSensor:
                      return DistanceSensorListTile(
                          deviceState: deviceState,
                          onClick: () => apiService.sendRequest(
                              deviceState.deviceId, "measure", ""),
                          showDeviceSettings: () =>
                              _showDeviceSettingsPage(deviceState, apiService));
                    default:
                      return UnknownListTile(deviceState);
                  }
                },
              );
            });
      },
    );
  }

  void _showDeviceSettingsPage(
      DeviceState deviceState, IApiService apiService) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DeviceSettingsPage(deviceState, apiService)));
  }
}
