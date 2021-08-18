import 'package:curtains_client/models/connection/index.dart';
import 'package:curtains_client/screens/main/components/helper/skeleton-tile.dart';
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
            Text(
              _getTitleMessage(info),
              style: Theme.of(context).textTheme.headline5,
            ),
            if (info != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
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
    if (info != null && info.isProxy && info.proxiedAddress == null) {
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

class ConnectingListPlaceholder extends StatelessWidget {
  final ConnectionInfo? info;

  ConnectingListPlaceholder(this.info);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final heightOfTile = 98;
    int count = (height / heightOfTile).floor();
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        return SkeletonTile();
      },
      itemCount: count,
    );
  }
}
