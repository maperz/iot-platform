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
        return Provider<IDeviceStateService>(
          create: (context) => deviceStateService,
          child: StreamBuilder<DeviceList>(
              stream: deviceStateService.getDevices(),
              builder: (context, deviceStatesSnapshot) {
                if (deviceStatesSnapshot.data == null) {
                  return Container();
                }

                final devices = deviceStatesSnapshot.data!;
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices.elementAt(index);
                    final type = device.type;

                    switch (type) {
                      case DeviceType.Curtain:
                        return CurtainListTile(device);
                      case DeviceType.Lamp:
                        return LampListTile(
                          device,
                          showDeviceSettings: () => _showDeviceSettingsPage(
                              device, deviceStateService),
                        );
                      case DeviceType.Thermo:
                        return ThermoListTile(
                            deviceStateService: deviceStateService,
                            deviceInfo: device,
                            onClick: () => apiService.sendRequest(
                                device.id, "temperature", ""),
                            showDeviceSettings: () => _showDeviceSettingsPage(
                                device, deviceStateService));
                      case DeviceType.DistanceSensor:
                        return DistanceSensorListTile(
                            deviceInfo: device,
                            onClick: () => apiService.sendRequest(
                                device.id, "measure", ""),
                            showDeviceSettings: () => _showDeviceSettingsPage(
                                device, deviceStateService));
                      default:
                        return UnknownListTile(device);
                    }
                  },
                );
              }),
        );
      },
    );
  }

  void _showDeviceSettingsPage(
      DeviceInfo deviceInfo, IDeviceStateService deviceStateService) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DeviceSettingsPage(deviceInfo, deviceStateService)));
  }
}
