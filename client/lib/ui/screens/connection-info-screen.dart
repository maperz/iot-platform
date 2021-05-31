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
            ConnectionInfo? info = infoSnapShot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Connection Info"),
                ..._createStatusWidget(info),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/icons/connection-icon.png"),
                    ),
                  ),
                )
              ],
            );
          },
        );
      }),
    );
  }

  List<Widget> _createStatusWidget(ConnectionInfo? info) {
    final notConnectedText =
        Text("Not connected", style: TextStyle(color: Color(0xFF725F)));
    final connectedText =
        Text("Connected", style: TextStyle(color: Color(0xA5FF5F)));

    if (info == null || !info.isConnected) {
      return [notConnectedText];
    }

    return [
      connectedText,
      Text(
          "${info.isProxy ? "Proxied" : "Directly"} via ${info.isProxy ? info.proxiedAddress : info.targetAddress} ",
          style: TextStyle(color: Color(0xA5FF5F)))
    ];
  }
}
