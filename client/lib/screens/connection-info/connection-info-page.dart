import 'package:iot_client/models/connection/index.dart';
import 'package:iot_client/services/connection/connection.dart';
import 'package:flutter/material.dart';

class ConnectionInfoPage extends StatelessWidget {
  final IConnectionService connectionService;

  const ConnectionInfoPage({required this.connectionService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Connectivity Info'),
        ),
        body: Center(
            child: StreamBuilder<ConnectionStateData>(
          stream: connectionService.getConnectedState(),
          builder: (context, infoSnapShot) {
            ConnectionInfo? info = infoSnapShot.data?.info;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32.0, horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._createStatusWidget(info),
                    ],
                  ),
                ),
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
        )));
  }

  List<Widget> _createStatusWidget(ConnectionInfo? info) {
    final commonStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 18);

    final notConnectedText = Text("Not connected",
        style: commonStyle.copyWith(color: Color(0xFFFF725F)));

    if (info == null || !info.isConnected) {
      return [notConnectedText];
    }

    final connectedText = Text("Connected",
        style: commonStyle.copyWith(color: Color(0xFFA5FF5F)));

    final spacer = Container(
      height: 6,
    );

    return [
      connectedText,
      spacer,
      Text(
          "${info.isProxy ? "Proxied" : "Directly"} via ${info.isProxy ? info.proxiedAddress : info.targetAddress} ",
          style: commonStyle),
      spacer,
      Text("Hub ID: ${info.hubId}", style: commonStyle),
      spacer,
      Text("Version: ${info.version}", style: commonStyle)
    ];
  }
}
