import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/helper/device_state_stream_builder.dart';
import 'package:iot_client/services/device/device_state_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceSettingsPage extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final IDeviceStateService deviceStateService;

  final nameController = TextEditingController();

  DeviceSettingsPage(this.deviceInfo, this.deviceStateService, {Key? key})
      : super(key: key) {
    nameController.text = deviceInfo.getDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(deviceInfo.getDisplayName()),
    );

    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    hintText: "Device Name",
                    labelText: 'Name:',
                    helperText: "Change the name of the device"),
                onFieldSubmitted: (newName) async {
                  await _changeDeviceName(newName);
                  Navigator.pop(context);
                }),
            Container(
              height: 20,
            ),
            TextFormField(
              enabled: false,
              initialValue: deviceInfo.id.toString(),
              decoration: const InputDecoration(
                labelText: "Device Id",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: deviceInfo.type.toString(),
              decoration: const InputDecoration(
                labelText: "Device Type",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: deviceInfo.version,
              decoration: const InputDecoration(
                labelText: "Device Version",
              ),
            ),
            Provider<IDeviceStateService>(
              create: (_) => deviceStateService,
              child: DeviceStateStreamBuilder(
                  deviceId: deviceInfo.id,
                  builder: (context, deviceState) => TextFormField(
                        enabled: false,
                        initialValue:
                            deviceState.lastUpdate.toLocal().toString(),
                        decoration: const InputDecoration(
                          labelText: "Last Update",
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Future _changeDeviceName(String newName) {
    return deviceStateService.setDeviceName(deviceInfo.id, newName);
  }
}
