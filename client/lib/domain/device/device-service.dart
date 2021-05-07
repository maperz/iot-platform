import 'package:curtains_client/connection/connection.dart';
import 'package:rxdart/subjects.dart';
import 'device-endpoints.dart';
import 'device-state.dart';

abstract class IDeviceListService {
  Stream<Iterable<DeviceState>> getDeviceList();
}

class DeviceListService implements IDeviceListService {
  final IConnection _connection;
  BehaviorSubject<Iterable<DeviceState>> _devices = BehaviorSubject.seeded([]);

  DeviceListService(this._connection) {
    _connection
        .getConnectedState()
        .where((connected) => connected)
        .distinct()
        .listen((_) {
      _onConnected();
    });
  }

  void _onConnected() async {
    _connection.listenOn(Endpoints.DeviceStateChangedEndpoint, (updateList) {
      if (updateList != null) {
        Iterable<DeviceState> updatedDevices =
            updateList.map((json) => DeviceState.fromJson(json));
        _devices.add(updatedDevices);
      }
    });

    var rawResponse = await _connection.getDeviceList();
    var deviceList = rawResponse.map((json) => DeviceState.fromJson(json));

    _devices.add(deviceList);
  }

  @override
  Stream<Iterable<DeviceState>> getDeviceList() {
    return _devices.stream;
  }
}
