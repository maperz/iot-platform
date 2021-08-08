import 'package:curtains_client/api/api-service.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:rxdart/subjects.dart';
import 'device-endpoints.dart';
import 'device-state.dart';

import 'package:rxdart/rxdart.dart';

abstract class IDeviceListService {
  Stream<Iterable<DeviceState>> getDeviceList();
}

class DeviceListService implements IDeviceListService {
  final IApiService apiService;
  final IConnectionService connectionService;

  BehaviorSubject<Iterable<DeviceState>> _devices = BehaviorSubject.seeded([]);

  DeviceListService(
      {required this.apiService, required this.connectionService}) {
    init();
  }

  Future init() async {
    var onConnected = connectionService
        .isConnected()
        .where((connected) => connected)
        .distinct();

    var updateStatesStream = connectionService
        .listenOn<List<dynamic>>(Endpoints.DeviceStateChangedEndpoint)
        .where((updateList) => updateList.length > 0)
        .map((updateList) =>
            updateList.map((json) => DeviceState.fromJson(json)).toList());

    onConnected
        .asyncMap((_) => _fetchDeviceList())
        .switchMap(
            (startList) => updateStatesStream.startWith(startList.toList()))
        .listen((updatedStates) {
      _devices.add(updatedStates);
    });
  }

  Future<Iterable<DeviceState>> _fetchDeviceList() async {
    var rawResponse = await apiService.getDeviceList();
    return rawResponse.map((json) => DeviceState.fromJson(json));
  }

  @override
  Stream<Iterable<DeviceState>> getDeviceList() {
    return _devices.stream;
  }
}
