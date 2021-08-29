import 'package:curtains_client/models/device/models/device-state.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceSettingsPage extends StatelessWidget {
  final DeviceState state;
  final IApiService apiService;
  final nameController = TextEditingController();

  DeviceSettingsPage(this.state, this.apiService) {
    nameController.text = state.getDisplayName();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(this.state.getDisplayName()),
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
              initialValue: this.state.deviceId.toString(),
              decoration: const InputDecoration(
                labelText: "Device Id",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: this.state.info.type.toString(),
              decoration: const InputDecoration(
                labelText: "Device Type",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: this.state.info.version,
              decoration: const InputDecoration(
                labelText: "Device Version",
              ),
            ),
            TextFormField(
              enabled: false,
              initialValue: this.state.lastUpdate.toLocal().toString(),
              decoration: const InputDecoration(
                labelText: "Last Update",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _changeDeviceName(String newName) {
    return this.apiService.setDeviceName(this.state.deviceId, newName);
  }
}
