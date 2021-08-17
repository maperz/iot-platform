import 'dart:convert';

import 'package:curtains_client/api/api-service.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:curtains_client/ui/helper/last-update-text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../device-detail.dart';
import '../device-icon.dart';

class DistanceSensorTile extends StatefulWidget {
  final DeviceState deviceState;
  late final DistanseSensorState thermoState;

  DistanceSensorTile(
    this.deviceState, {
    Key? key,
  }) : super(key: key) {
    this.thermoState = DistanseSensorState(this.deviceState.state);
  }

  @override
  _DistanceSensorTileState createState() => _DistanceSensorTileState();
}

class DistanseSensorState {
  late double distance;
  // late double change;

  DistanseSensorState(String jsonEncode) {
    final state = json.decode(jsonEncode);

    var tempJson = state['distance'] ?? "0.0";
    distance = tempJson is int ? (tempJson).toDouble() : tempJson;
  }
}

class _DistanceSensorTileState extends State<DistanceSensorTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => Card(
              child: InkWell(
                onTap: () => requestMeasurement(apiService),
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
                        Container(
                          width: 10,
                        ),
                        Text(widget.thermoState.distance.toString() + "cm"),
                      ],
                    ),
                    subtitle: LastUpdateText(widget.deviceState.lastUpdate)),
              ),
            ));
  }

  void requestMeasurement(IApiService apiService) {
    apiService.sendRequest(widget.deviceState.deviceId, "temperature", "");
  }
}
