import 'package:iot_client/models/connection/models/connection_info.dart';
import 'package:flutter/material.dart';

import 'components/index.dart';

class ConnectionPlaceholderPage extends StatelessWidget {
  final ConnectionInfo? info;
  final String? alternativeStatus;

  const ConnectionPlaceholderPage({this.info, this.alternativeStatus, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var title = _getTitleMessage(info);
    var status = _getStatusMessage(info) ?? alternativeStatus;

    return Stack(children: [
      const ConnectingListPlaceholder(),
      ConnectingPlaceholderInfo(
        title: title,
        status: status,
      )
    ]);
  }

  String _getTitleMessage(ConnectionInfo? info) {
    if (info != null && info.isProxy && info.proxiedAddress == null) {
      return "Hub offline";
    }

    return "Establishing connection";
  }

  String? _getStatusMessage(ConnectionInfo? info) {
    if (info == null) {
      return null;
    }

    if (info.isProxy && info.proxiedAddress == null) {
      if (info.hubId != null) {
        return "Make sure the hub is running and connected to the internet.";
      }
      return "Please connect a hub instance to your account!";
    }

    return "Connecting to ${info.targetAddress}";
  }
}
