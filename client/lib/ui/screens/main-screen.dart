import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/ui/screens/connection-info-screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../device-list.dart';
import 'connecting-placeholder.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(builder: (context, connection, child) {
      return StreamBuilder<ConnectionInfo?>(
        stream: connection.getConnectionInfo(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          if (snapshot.hasData && info != null && info.isConnected) {
            return DeviceListWidget();
          }
          return StreamBuilder(
              stream: connection.getConnectionAddress(),
              builder: (context, address) {
                return ConnectingPlaceholder(info);
              });
        },
      );
    });
  }
}
