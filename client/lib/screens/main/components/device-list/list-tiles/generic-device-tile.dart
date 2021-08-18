import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/main/components/helper/last-update-text.dart';
import 'package:flutter/material.dart';

import '../device-icon.dart';

typedef OnDeviceClickedCallback = Function();
typedef ShowDeviceDetailCallback = Function();

class GenericDeviceTile extends StatelessWidget {
  final DeviceState deviceState;

  final OnDeviceClickedCallback? onClick;
  final ShowDeviceDetailCallback? showDeviceDetail;

  final WidgetBuilder builder;

  const GenericDeviceTile(
      {required this.deviceState,
      this.onClick,
      this.showDeviceDetail,
      required this.builder,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onClick,
        child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            enabled: deviceState.connected,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DeviceIcon(deviceState),
            ),
            trailing: InkWell(
              onTap: deviceState.connected ? showDeviceDetail : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(deviceState.getDisplayName()),
                Container(
                  width: 10,
                ),
                builder(context),
              ],
            ),
            subtitle: LastUpdateText(deviceState.lastUpdate)),
      ),
    );
  }
}
