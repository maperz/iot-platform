import 'package:curtains_client/services/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionInfoIcon extends StatelessWidget {
  const ConnectionInfoIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IConnectionService>(builder: (context, connection, child) {
      return StreamBuilder<ConnectionStateData>(
        stream: connection.getConnectedState(),
        builder: (context, snapshot) {
          final info = snapshot.data?.info;
          if (snapshot.hasData && info != null && info.isConnected) {
            return Icon(
              Icons.check,
              color: Colors.green,
            );
          }
          return Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
              ));
        },
      );
    });
  }
}
