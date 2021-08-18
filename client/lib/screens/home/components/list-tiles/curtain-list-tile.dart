import 'dart:convert';

import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/device-detail/device-detail.dart';
import 'package:curtains_client/screens/home/components/device-icon.dart';
import 'package:curtains_client/screens/home/components/helper/last-update-text.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CurtainListTile extends StatefulWidget {
  final DeviceState deviceState;
  late final CurtainState curtainState;

  CurtainListTile(
    this.deviceState, {
    Key? key,
  }) : super(key: key) {
    this.curtainState = CurtainState(this.deviceState.state);
  }

  @override
  _CurtainListTileState createState() => _CurtainListTileState();
}

class CurtainState {
  /* Example curtain state
   * {
   *  speed: "1.0",
   * }
   */

  late double progress;

  CurtainState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var speedJson = state['speed'];
    progress = speedJson is int ? (speedJson).toDouble() : speedJson;
  }
}

class _CurtainListTileState extends State<CurtainListTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => Card(
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  enabled: widget.deviceState.connected,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DeviceIcon(widget.deviceState),
                  ),
                  trailing: InkWell(
                    onTap: widget.deviceState.connected
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailDevicePage(
                                        widget.deviceState, apiService)));
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
                      Text(widget.deviceState.getDisplayName()),
                      Expanded(
                        child: Slider(
                          value: widget.curtainState.progress,
                          min: -1.0,
                          max: 1.0,
                          divisions: 40,
                          label: (widget.curtainState.progress * 100)
                                  .round()
                                  .toString() +
                              " Percent",
                          onChanged: widget.deviceState.connected
                              ? (double value) {
                                  setState(() => setSpeed(apiService, value));
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  subtitle: LastUpdateText(widget.deviceState.lastUpdate)),
            ));
  }

  void setSpeed(IApiService apiService, double value) {
    apiService.sendRequest(
        widget.deviceState.deviceId, "speed", value.toStringAsPrecision(2));
  }
}
