import 'package:curtains_client/api/api-service.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:logging/logging.dart';
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
  final logger = Logger("DeviceListService");

  BehaviorSubject<Iterable<DeviceState>> _devices = BehaviorSubject.seeded([]);

  DeviceListService(
      {required this.apiService, required this.connectionService}) {
    init();
  }

  Future init() async {
    var onConnected = connectionService
        .isConnected()
        .distinct()
        .where((connected) => connected);

    onConnected
        .asyncMap((_) => _fetchDeviceList())
        .switchMap(
            (startList) => _getUpdateStream().startWith(startList.toList()))
        .listen((updatedStates) {
      //logger.fine("Updating device states for ${updatedStates.length} devices");
      _devices.add(updatedStates);
    });
  }

  Stream<Iterable<DeviceState>> _getUpdateStream() {
    return connectionService
        .listenOn<List<dynamic>>(Endpoints.DeviceStateChangedEndpoint)
        .where((updateList) => updateList.length > 0)
        .map((updateList) =>
            updateList.map((json) => DeviceState.fromJson(json)).toList());
  }

  Future<Iterable<DeviceState>> _fetchDeviceList() async {
    logger.info("Fetching device list");
    var rawResponse = await apiService.getDeviceList();
    return rawResponse.map((json) => DeviceState.fromJson(json));
  }

  @override
  Stream<Iterable<DeviceState>> getDeviceList() {
    return _devices.stream;
  }
}
