import 'package:flutter/material.dart';

class ConnectingPlaceholderInfo extends StatelessWidget {
  final String title;
  final String? status;

  const ConnectingPlaceholderInfo(
      {required this.title, required this.status, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                status!,
                style:
                    Theme.of(context).textTheme.caption!.copyWith(fontSize: 18),
              ),
            )
        ],
      ),
    );
  }
}
