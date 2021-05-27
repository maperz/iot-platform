import 'package:curtains_client/connection/connection.dart';
import 'package:flutter/material.dart';

class ConnectingPlaceholder extends StatelessWidget {
  final ConnectionInfo? info;

  ConnectingPlaceholder(this.info);

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
              _getTitleMessage(info),
              style: Theme.of(context).textTheme.headline5,
            ),
            if (info != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _getStatusMessage(info!),
                  style: Theme.of(context).textTheme.caption,
                ),
              )
          ],
        ),
      ),
    );
  }

  String _getTitleMessage(ConnectionInfo? info) {
    if (info == null) {
      return "Searching for endpoint";
    }

    if (info.isProxy && info.proxiedAddress == null) {
      return "Hub offline";
    }

    return "Establishing connection";
  }

  String _getStatusMessage(ConnectionInfo info) {
    if (info.isProxy && info.proxiedAddress == null) {
      return "Make sure the hub is up and running.";
    }

    return "Connecting to ${info.targetAddress}";
  }
}
