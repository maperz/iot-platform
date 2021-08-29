import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlideableListMenu extends StatelessWidget {
  final Widget child;
  final bool? enabled;
  final Function? onSettingsPressed;

  const SlideableListMenu(
      {Key? key, required this.child, this.enabled, this.onSettingsPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: enabled ?? true,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            label: 'Settings',
            backgroundColor: Colors.black54,
            icon: Icons.settings,
            onPressed: (context) {
              if (onSettingsPressed != null) {
                onSettingsPressed!();
              }
            },
          ),
        ],
      ),
      child: child,
    );
  }
}
