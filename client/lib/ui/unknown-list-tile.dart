import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'device-detail.dart';
import 'device-icon.dart';

class UnknownListTile extends StatelessWidget {
  final DeviceState _deviceState;

  UnknownListTile(this._deviceState);

  @override
  Widget build(BuildContext context) {
    return Consumer<Connection>(
        builder: (context, connection, child) => Card(
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
                                        _deviceState, connection)));
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.more_vert_rounded,
                      ),
                    ),
                  ),
                  title: Text(_deviceState.getDisplayName())),
            ));
  }
}
