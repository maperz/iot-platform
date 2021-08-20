import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:curtains_client/services/connection/connection.dart';
import 'package:logging/logging.dart';
import 'device-endpoints.dart';

import 'package:rxdart/rxdart.dart';

typedef DeviceStateMap = Map<String?, DeviceState>;
typedef DeviceStateList = Iterable<DeviceState>;

abstract class IDeviceListService {
  Stream<DeviceStateList> getDeviceStateUpdates();
}

class DeviceListService implements IDeviceListService {
  final IApiService apiService;
  final IConnectionService connectionService;
  final logger = Logger("DeviceListService");

  Stream<DeviceStateList>? _deviceUpdates;
  Stream<DeviceStateList>? _deviceStates;

  DeviceListService(
      {required this.apiService, required this.connectionService});

  @override
  Stream<Iterable<DeviceState>> getDeviceStateUpdates() {
    if (_deviceUpdates == null) {
      var onConnected = connectionService
          .isConnected()
          .distinct()
          .where((connected) => connected);

      _deviceUpdates = onConnected
          .asyncMap((_) => _fetchDeviceList())
          .switchMap(
              (startList) => _getUpdateStream().startWith(startList.toList()))
          .shareReplay(maxSize: 1);
    }

    return _deviceUpdates!;
  }

  @override
  Stream<DeviceStateList> getDeviceStates() {
    if (_deviceStates == null) {
      final accumulateStatesTransformer =
          ScanStreamTransformer<DeviceStateList, DeviceStateMap>(
              (states, updates, i) {
        for (var state in updates) {
          states[state.deviceId] = state;
        }

        return states;
      }, DeviceStateMap());

      var stateMapStream = getDeviceStateUpdates()
          .transform<DeviceStateMap>(accumulateStatesTransformer);

      _deviceStates =
          stateMapStream.map((stateMap) => stateMap.values.toList());
    }

    return _deviceStates!;
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
}
