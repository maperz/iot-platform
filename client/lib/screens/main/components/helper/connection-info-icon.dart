import 'package:curtains_client/services/connection/connection.dart';
import 'package:flutter/material.dart';

class ConnectionInfoIcon extends StatelessWidget {
  final IConnectionService connectionService;

  const ConnectionInfoIcon({required this.connectionService, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStateData>(
      stream: connectionService.getConnectedState(),
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
  }
}
