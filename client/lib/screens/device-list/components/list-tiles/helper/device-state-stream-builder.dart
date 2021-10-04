import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/services/device/device-state-service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef DeviceStateBuilder = Widget Function(BuildContext, DeviceState);

class DeviceStateStreamBuilder<T> extends StatelessWidget {
  final String deviceId;
  final DeviceStateBuilder builder;

  const DeviceStateStreamBuilder(
      {required this.deviceId, required this.builder, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IDeviceStateService>(
        builder: (context, deviceStateService, child) =>
            StreamBuilder<DeviceState>(
              stream: deviceStateService.getDeviceStateUpdates(deviceId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  var deviceState = snapshot.data!;
                  return builder(context, deviceState);
                }
                return Container();
              },
            ));
  }
}
