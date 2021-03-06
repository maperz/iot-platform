import 'package:iot_client/screens/device-list/components/device_list.dart';
import 'package:iot_client/services/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/connection-placeholder/connection_placeholder_page.dart';

class DeviceListPage extends StatelessWidget {
  const DeviceListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IConnectionService>(
      builder: (context, connectionService, child) =>
          StreamBuilder<ConnectionStateData>(
              stream: connectionService.getConnectedState(),
              builder: (context, snapshot) {
                final info = snapshot.data?.info;
                if (snapshot.hasData && info != null && info.isConnected) {
                  return const DeviceListWidget();
                }
                return ConnectionPlaceholderPage(
                  info: info,
                  alternativeStatus: "Trying to establish a connection ...",
                );
              }),
    );
  }
}
