import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/device-list/components/list-tiles/helper/slidable-list-menu.dart';
import 'package:curtains_client/screens/main/components/helper/friendly-change-text.dart';
import 'package:flutter/material.dart';

import '../../device-icon.dart';

typedef OnDeviceClickedCallback = Function();
typedef ShowDeviceDetailCallback = Function();

class GenericDeviceTile extends StatelessWidget {
  final DeviceState deviceState;

  final OnDeviceClickedCallback? onClick;
  final ShowDeviceDetailCallback? showDeviceSettings;

  final WidgetBuilder builder;
  final WidgetBuilder? detailBuilder;

  const GenericDeviceTile(
      {required this.deviceState,
      this.onClick,
      this.showDeviceSettings,
      required this.builder,
      this.detailBuilder,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        //onTap: onClick,
        child: SlideableListMenu(
            enabled: deviceState.connected,
            onSettingsPressed: showDeviceSettings,
            child: detailBuilder != null
                ? ExpansionTile(
                    key: PageStorageKey(deviceState.deviceId),
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    children: [detailBuilder!(context)],
                    leading: _getLeading(context),
                    title: _getTitle(context),
                    subtitle: _getSubtitle(context))
                : ListTile(
                    onTap: onClick,
                    enabled: deviceState.connected,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    leading: _getLeading(context),
                    title: _getTitle(context),
                    subtitle: _getSubtitle(context))),
      ),
    );
  }

  Widget _getLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DeviceIcon(deviceState),
    );
  }

  Widget _getTitle(BuildContext context) {
    return Row(
      children: [
        Text(deviceState.getDisplayName()),
        Container(
          width: 10,
        ),
        builder(context),
      ],
    );
  }

  Widget _getSubtitle(BuildContext context) {
    return FriendlyChangeText(
      deviceState.lastUpdate,
      key: UniqueKey(),
    );
  }
}
