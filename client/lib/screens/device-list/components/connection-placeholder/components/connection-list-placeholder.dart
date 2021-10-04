import 'package:iot_client/screens/main/components/helper/skeleton-tile.dart';
import 'package:flutter/material.dart';

class ConnectingListPlaceholder extends StatelessWidget {
  ConnectingListPlaceholder();

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
