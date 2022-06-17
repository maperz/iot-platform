import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/air_quality_tile.dart';
import 'package:iot_client/screens/device-settings/device_settings_page.dart';
import 'package:iot_client/services/api/api_service.dart';
import 'package:iot_client/services/connection/connection.dart';
import 'package:iot_client/services/device/device_state_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './list-tiles/index.dart';

class DeviceListWidget extends StatefulWidget {
  const DeviceListWidget({Key? key}) : super(key: key);

  @override
  _DeviceListWidgetState createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<IConnectionService, IApiService>(
      builder: (context, connectionService, apiService, child) {
        IDeviceStateService deviceStateService = DeviceListService(
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
                      case DeviceType.curtain:
                        return CurtainListTile(device);
                      case DeviceType.lamp:
                        return LampListTile(
                          device,
                          showDeviceSettings: () => _showDeviceSettingsPage(
                              device, deviceStateService),
                        );
                      case DeviceType.thermometer:
                        return ThermoListTile(
                            deviceStateService: deviceStateService,
                            deviceInfo: device,
                            onClick: () => apiService.sendRequest(
                                device.id, "temperature", ""),
                            showDeviceSettings: () => _showDeviceSettingsPage(
                                device, deviceStateService));
                      case DeviceType.distanceSensor:
                        return DistanceSensorListTile(
                            deviceInfo: device,
                            onClick: () => apiService.sendRequest(
                                device.id, "measure", ""),
                            showDeviceSettings: () => _showDeviceSettingsPage(
                                device, deviceStateService));
                      case DeviceType.airqualitySensor:
                        return AirQualityTile(
                            deviceInfo: device,
                            onClick: () => apiService.sendRequest(
                                device.id, "quality", ""),
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
