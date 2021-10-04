import 'package:iot_client/models/device/index.dart';
import 'package:iot_client/services/api/api-service.dart';
import 'package:iot_client/services/connection/connection.dart';
import 'package:logging/logging.dart';
import 'device-endpoints.dart';
import 'package:collection/collection.dart';

import 'package:rxdart/rxdart.dart';

typedef DeviceStateMap = Map<String?, DeviceState>;

typedef DeviceList = Iterable<DeviceInfo>;

typedef DeviceStateList = Iterable<DeviceState>;

abstract class IDeviceStateService {
  Stream<DeviceList> getDevices();
  Stream<DeviceState> getDeviceStateUpdates(String deviceId);

  Future<DeviceStateList> getStateHistory(String deviceId,
      {DateTime? start,
      DateTime? end,
      int? intervalSeconds,
      int? count,
      DeviceType? type});

  Future sendRequest(String deviceId, String name, String payload);

  Future setDeviceName(String deviceId, String name);
}

class DeviceListService implements IDeviceStateService {
  final IApiService apiService;
  final IConnectionService connectionService;
  final logger = Logger("DeviceListService");

  Stream<DeviceStateList>? _deviceUpdates;
  Stream<DeviceStateList>? _deviceStates;

  DeviceListService(
      {required this.apiService, required this.connectionService});

  @override
  Future<DeviceStateList> getStateHistory(String deviceId,
      {DateTime? start,
      DateTime? end,
      int? intervalSeconds,
      int? count,
      DeviceType? type}) async {
    logger.info("Fetching history for device $deviceId");
    var rawResponse = await apiService.getDeviceStateHistory(deviceId,
        start: start, end: end, intervalSeconds: intervalSeconds, count: count);
    var stateHistoryList = _mapJsonToDeviceStateList(rawResponse);

    if (type != null) {
      stateHistoryList =
          stateHistoryList.where((state) => state.info.type == type);
    }

    return stateHistoryList;
  }

  Stream<Iterable<DeviceState>> _getUpdateStream() {
    return connectionService
        .listenOn<List<dynamic>>(Endpoints.DeviceStateChangedEndpoint)
        .where((updateList) => updateList.length > 0)
        .map((raw) => _mapJsonToDeviceStateList(raw).toList());
  }

  Future<Iterable<DeviceState>> _fetchDeviceList() async {
    logger.info("Fetching device list");
    var rawResponse = await apiService.getDeviceList();
    return _mapJsonToDeviceStateList(rawResponse);
  }

  Iterable<DeviceState> _mapJsonToDeviceStateList(Iterable<dynamic> raw) {
    return raw.map((json) => DeviceState.fromJson(json));
  }

  @override
  Stream<DeviceList> getDevices() {
    return _getDeviceStates()
        .map((states) => states.map((state) => state.info).toList())
        .distinct(ListEquality().equals)
        .map((element) {
      print("Devices Changed:" + element.toString());
      return element;
    });
  }

  @override
  Stream<DeviceState> getDeviceStateUpdates(String deviceId) {
    return _getDeviceStates()
        .where((states) => states.any((state) => state.deviceId == deviceId))
        .map((states) =>
            states.firstWhere((state) => state.deviceId == deviceId))
        .distinct();
  }

  Stream<Iterable<DeviceState>> _getAllDeviceStateUpdates() {
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

  Stream<DeviceStateList> _getDeviceStates() {
    if (_deviceStates == null) {
      final accumulateStatesTransformer =
          ScanStreamTransformer<DeviceStateList, DeviceStateMap>(
              (states, updates, i) {
        for (var state in updates) {
          states[state.deviceId] = state;
        }

        return states;
      }, DeviceStateMap());

      var stateMapStream = _getAllDeviceStateUpdates()
          .transform<DeviceStateMap>(accumulateStatesTransformer);

      _deviceStates = stateMapStream
          .map((stateMap) => stateMap.values.toList())
          .shareReplay(maxSize: 1);
    }

    return _deviceStates!;
  }

  @override
  Future sendRequest(String deviceId, String name, String payload) {
    return apiService.sendRequest(deviceId, name, payload);
  }

  @override
  Future setDeviceName(String deviceId, String name) {
    return apiService.setDeviceName(deviceId, name);
  }
}
