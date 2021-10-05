import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/models/device/models/domain-states/curtain_state.dart';
import 'package:iot_client/screens/device-list/components/list-tiles/helper/device_state_stream_builder.dart';
import 'package:iot_client/screens/device-settings/device_settings_page.dart';
import 'package:iot_client/screens/main/components/helper/friendly_change_text.dart';
import 'package:iot_client/services/device/device_state_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../device_icon.dart';

class CurtainListTile extends StatefulWidget {
  final DeviceInfo deviceInfo;

  const CurtainListTile(
    this.deviceInfo, {
    Key? key,
  }) : super(key: key);

  @override
  _CurtainListTileState createState() => _CurtainListTileState();
}

class _CurtainListTileState extends State<CurtainListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IDeviceStateService>(
        builder: (context, deviceStateService, child) => Card(
              child: DeviceStateStreamBuilder(
                  deviceId: widget.deviceInfo.id,
                  builder: (context, deviceState) {
                    var curtainState = CurtainState.fromJson(deviceState.state);

                    return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        enabled: deviceState.connected,
                        leading: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DeviceIcon(deviceState),
                        ),
                        trailing: InkWell(
                          onTap: deviceState.connected
                              ? () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DeviceSettingsPage(
                                                  widget.deviceInfo,
                                                  deviceStateService)));
                                }
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_vert_rounded,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(deviceState.getDisplayName()),
                            Expanded(
                              child: Slider(
                                value: curtainState.progress,
                                min: -1.0,
                                max: 1.0,
                                divisions: 40,
                                label: (curtainState.progress * 100)
                                        .round()
                                        .toString() +
                                    " Percent",
                                onChanged: deviceState.connected
                                    ? (double value) {
                                        setState(() => setSpeed(
                                            deviceStateService,
                                            value,
                                            deviceState));
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        subtitle: FriendlyChangeText(deviceState.lastUpdate,
                            key: UniqueKey()));
                  }),
            ));
  }

  void setSpeed(IDeviceStateService deviceStateService, double value,
      DeviceState deviceState) {
    deviceStateService.sendRequest(
        deviceState.deviceId, "speed", value.toStringAsPrecision(2));
  }
}
