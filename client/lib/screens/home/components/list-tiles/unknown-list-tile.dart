import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/screens/home/components/helper/last-update-text.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../device-detail/device-detail.dart';
import '../device-icon.dart';

class UnknownListTile extends StatelessWidget {
  final DeviceState _deviceState;

  UnknownListTile(this._deviceState);

  @override
  Widget build(BuildContext context) {
    return Consumer<IApiService>(
        builder: (context, apiService, child) => Card(
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                enabled: _deviceState.connected,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DeviceIcon(_deviceState),
                ),
                trailing: InkWell(
                  onTap: _deviceState.connected
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailDevicePage(
                                      _deviceState, apiService)));
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.more_vert_rounded,
                    ),
                  ),
                ),
                title: Text(_deviceState.getDisplayName() + " (Unknown Type)"),
                subtitle: LastUpdateText(_deviceState.lastUpdate))));
  }
}