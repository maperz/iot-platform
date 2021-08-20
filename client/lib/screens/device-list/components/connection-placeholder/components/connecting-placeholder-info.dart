import 'package:curtains_client/models/connection/index.dart';
import 'package:flutter/material.dart';

class ConnectingPlaceholderInfo extends StatelessWidget {
  final String title;
  final String? status;

  ConnectingPlaceholderInfo({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline5,
            ),
            if (status != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  status!,
                  style: Theme.of(context).textTheme.caption,
                ),
              )
          ],
        ),
      ),
    );
  }
}