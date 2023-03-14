import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/helper/device_state_stream_builder.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/helper/slidable_list_menu.dart';
import 'package:iot_client/screens/main/components/helper/friendly_change_text.dart';
import 'package:flutter/material.dart';

import '../../device_icon.dart';
import 'detail_list_tile.dart';

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
                      ? DetailListTile(
                          active: deviceState.connected,
                          key: PageStorageKey(deviceState.deviceId),
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          leading: _getLeading(context, deviceState),
                          title: _getTitle(context, deviceState),
                          subtitle: _getSubtitle(context, deviceState),
                          child: detailBuilder!(context, deviceState))
                      : ListTile(
                          onTap: onClick,
                          enabled: deviceState.connected,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
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
