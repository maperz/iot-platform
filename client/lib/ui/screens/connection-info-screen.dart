import 'package:curtains_client/connection/connection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectionInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<Connection>(builder: (context, connection, child) {
        return StreamBuilder<ConnectionInfo?>(
          stream: connection.getConnectionInfo(),
          builder: (context, infoSnapShot) {
            if (infoSnapShot.hasData && infoSnapShot.data != null) {
              var info = infoSnapShot.data!;

              return Column(
                children: [
                  Text("Connection Info"),
                  Text(info.isConnected.toString()),
                  Text(info.isProxy.toString()),
                  Text(info.proxiedAddress ?? "NULL"),
                  Text(info.version),
                ],
              );
            }

            return Text("No connection");
          },
        );
      }),
    );
  }
}
