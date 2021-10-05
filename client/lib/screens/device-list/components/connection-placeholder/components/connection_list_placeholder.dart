import 'package:iot_client/screens/main/components/helper/skeleton_tile.dart';
import 'package:flutter/material.dart';

class ConnectingListPlaceholder extends StatelessWidget {
  const ConnectingListPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    const heightOfTile = 98;
    int count = (height / heightOfTile).floor();
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        return const SkeletonTile();
      },
      itemCount: count,
    );
  }
}
