import 'package:curtains_client/models/device/index.dart';
import 'package:curtains_client/services/device/device-service.dart';
import 'package:flutter/foundation.dart';

class DeviceListModel extends ChangeNotifier {
  final IDeviceListService _deviceListService;
  final Map<String?, DeviceState> _states = new Map();

  DeviceListModel(this._deviceListService) {
    _deviceListService.getDeviceList().listen(_updateStates);
  }

  void _updateStates(Iterable<DeviceState> states) {
    for (var state in states) {
      _states[state.deviceId] = state;
    }
    notifyListeners();
  }

  List<DeviceState> getDeviceStates() {
    return _states.values.toList();
  }
}
