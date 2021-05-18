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
                  hintText: "Some name",
                  labelText: 'Name:',
                ),
                onFieldSubmitted: (newName) async {
                  await _changeDeviceName(newName);
                  Navigator.pop(context);
                }),
            Container(
              height: 20,
            ),
            Text(
              "Device Id",
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              this.state.deviceId.toString(),
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const Divider(),
            Text(
              "Device Type",
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              this.state.info.type.toString(),
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const Divider(),
            Text(
              "Device Id",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
            Text(
              this.state.info.version,
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
            const Divider(),
            Text(
              "Last Update",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
            Text(
              this.state.lastUpdate.toLocal().toString(),
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            )
          ],
        ),
      ),
    );
  }

  Future _changeDeviceName(String newName) {
    return this.connection.setDeviceName(this.state.deviceId, newName);
  }
}
