import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/device-list/components/list-tiles/helper/device-state-stream-builder.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceSettingsPage extends StatelessWidget {
  final DeviceInfo deviceInfo;
  final IApiService apiService;
  final nameController = TextEditingController();

  DeviceSettingsPage(this.deviceInfo, this.apiService) {
    nameController.text = deviceInfo.getDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(this.deviceInfo.getDisplayName()),
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
              initialValue: this.deviceInfo.id.toString(),
              decoration: const InputDecoration(
                labelText: "Device Id",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: this.deviceInfo.type.toString(),
              decoration: const InputDecoration(
                labelText: "Device Type",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: this.deviceInfo.version,
              decoration: const InputDecoration(
                labelText: "Device Version",
              ),
            ),
            DeviceStateStreamBuilder(
                deviceId: deviceInfo.id,
                builder: (context, deviceState) => TextFormField(
                      enabled: false,
                      initialValue: deviceState.lastUpdate.toLocal().toString(),
                      decoration: const InputDecoration(
                        labelText: "Last Update",
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Future _changeDeviceName(String newName) {
    return this.apiService.setDeviceName(this.deviceInfo.id, newName);
  }
}
