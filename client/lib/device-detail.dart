import 'package:curtains_client/connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model/devices-model.dart';

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
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Some name",
                labelText: 'Name:',
              ),
              onEditingComplete: () =>
                  _changeDeviceName(this.nameController.text),
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
