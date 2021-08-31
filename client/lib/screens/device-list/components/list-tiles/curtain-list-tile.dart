import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/models/device/models/domain-states/curtain-state.dart';
import 'package:curtains_client/screens/device-settings/device-settings-page.dart';
import 'package:curtains_client/screens/main/components/helper/friendly-change-text.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:curtains_client/services/device/device-state-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../device-icon.dart';

class CurtainListTile extends StatefulWidget {
  final DeviceInfo deviceInfo;

  CurtainListTile(
    this.deviceInfo, {
    Key? key,
  }) : super(key: key);

  @override
  _CurtainListTileState createState() => _CurtainListTileState();
}

class _CurtainListTileState extends State<CurtainListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<IApiService, IDeviceStateService>(
        builder: (context, apiService, deviceStateService, child) => Card(
              child: StreamBuilder<DeviceState>(
                  stream: deviceStateService
                      .getDeviceStateUpdates(widget.deviceInfo.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Container();
                    }

                    var deviceState = snapshot.data!;
                    var curtainState = CurtainState.fromJson(deviceState.state);

                    return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                                                  apiService)));
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                            apiService, value, deviceState));
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

  void setSpeed(IApiService apiService, double value, DeviceState deviceState) {
    apiService.sendRequest(
        deviceState.deviceId, "speed", value.toStringAsPrecision(2));
  }
}
