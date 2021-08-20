import 'package:curtains_client/models/connection/models/connection-info.dart';
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
    var status = _getStatusMessage(info) ?? this.alternativeStatus;

    return Stack(children: [
      ConnectingListPlaceholder(),
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
      return "Make sure the hub is up and running.";
    }

    return "Connecting to ${info.targetAddress}";
  }
}
