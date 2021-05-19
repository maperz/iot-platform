import 'package:curtains_client/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../device-list.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(builder: (context, connection, child) {
      return StreamBuilder<bool>(
        stream: connection.getConnectedState(),
        builder: (context, connected) {
          if (connected.hasData && connected.data!) {
            return DeviceListWidget();
          }

          return StreamBuilder(
              stream: connection.getConnectionAddress(),
              builder: (context, address) {
                return ConnectingPlaceholder(address.data as String?);
              });
        },
      );
    });
  }
}

class ConnectingPlaceholder extends StatelessWidget {
  final String? address;
  ConnectingPlaceholder(this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CircularProgressIndicator(
                strokeWidth: 6,
              ),
            ),
            Text(
              address != null ? "Establishing connection" : "Discovering Hub",
              style: Theme.of(context).textTheme.headline5,
            ),
            if (address != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Connecting to Hub at $address',
                  style: Theme.of(context).textTheme.caption,
                ),
              )
          ],
        ),
      ),
    );
  }
}
