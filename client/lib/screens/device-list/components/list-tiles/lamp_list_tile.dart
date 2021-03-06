import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/lamp_state.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/helper/slidable_list_menu.dart';
import 'package:iot_client/screens/main/components/helper/friendly_change_text.dart';
import 'package:iot_client/services/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../device_icon.dart';
import 'helper/device_state_stream_builder.dart';

class LampListTile extends StatefulWidget {
  final DeviceInfo deviceInfo;
  final Function? showDeviceSettings;

  const LampListTile(
    this.deviceInfo, {
    this.showDeviceSettings,
    Key? key,
  }) : super(key: key);

  @override
  _LampListTileState createState() => _LampListTileState();
}

class _LampListTileState extends State<LampListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => DeviceStateStreamBuilder(
            deviceId: widget.deviceInfo.id,
            builder: (context, deviceState) {
              var lampState = LampState.fromJson(deviceState.state);

              return Card(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  decoration: BoxDecoration(
                      color: lampState.color.withOpacity(
                          (deviceState.connected && lampState.isOn) ? 1 : 0),
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: InkWell(
                    onTap: () => setState(() => setSwitchState(
                        apiService, !lampState.isOn, deviceState)),
                    child: SlideableListMenu(
                      enabled: deviceState.connected,
                      onSettingsPressed: widget.showDeviceSettings,
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          enabled: deviceState.connected,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DeviceIcon(deviceState),
                          ),
                          title: Text(deviceState.getDisplayName()),
                          subtitle: FriendlyChangeText(deviceState.lastUpdate,
                              key: UniqueKey())),
                    ),
                  ),
                ),
              );
            }));
  }

  void setSwitchState(
      IApiService apiService, bool value, DeviceState deviceState) {
    apiService.sendRequest(
        deviceState.deviceId, "switch", value ? "1.0" : "0.0");
  }
}
