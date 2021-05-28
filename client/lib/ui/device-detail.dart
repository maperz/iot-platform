import 'package:curtains_client/connection/connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../domain/device/device-state.dart';

class DetailDevicePage extends StatelessWidget {
  final DeviceState state;
  final Connection connection;
  final nameController = TextEditingController();

  DetailDevicePage(this.state, this.connection) {
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
    return this.connection.setDeviceName(this.state.deviceId, newName);
  }
}
