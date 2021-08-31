import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/device-list/components/list-tiles/helper/device-state-stream-builder.dart';
import 'package:curtains_client/screens/device-list/components/list-tiles/helper/slidable-list-menu.dart';
import 'package:curtains_client/screens/main/components/helper/friendly-change-text.dart';
import 'package:flutter/material.dart';

import '../../device-icon.dart';

typedef OnDeviceClickedCallback = Function();
typedef ShowDeviceDetailCallback = Function();

class GenericDeviceTile extends StatelessWidget {
  final DeviceInfo deviceInfo;

  final OnDeviceClickedCallback? onClick;
  final ShowDeviceDetailCallback? showDeviceSettings;

  final DeviceStateBuilder builder;
  final DeviceStateBuilder? detailBuilder;

  const GenericDeviceTile(
      {required this.deviceInfo,
      this.onClick,
      this.showDeviceSettings,
      required this.builder,
      this.detailBuilder,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DeviceStateStreamBuilder(
        deviceId: deviceInfo.id,
        builder: (context, deviceState) {
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
                          children: [detailBuilder!(context, deviceState)],
                          leading: _getLeading(context, deviceState),
                          title: _getTitle(context, deviceState),
                          subtitle: _getSubtitle(context, deviceState))
                      : ListTile(
                          onTap: onClick,
                          enabled: deviceState.connected,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          leading: _getLeading(context, deviceState),
                          title: _getTitle(context, deviceState),
                          subtitle: _getSubtitle(context, deviceState))),
            ),
          );
        });
  }

  Widget _getLeading(BuildContext context, DeviceState deviceState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DeviceIcon(deviceState),
    );
  }

  Widget _getTitle(BuildContext context, DeviceState deviceState) {
    return Row(
      children: [
        Text(deviceState.getDisplayName()),
        Container(
          width: 10,
        ),
        builder(context, deviceState),
      ],
    );
  }

  Widget _getSubtitle(BuildContext context, DeviceState deviceState) {
    return FriendlyChangeText(
      deviceState.lastUpdate,
      key: UniqueKey(),
    );
  }
}
