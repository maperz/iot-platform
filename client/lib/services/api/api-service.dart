import 'package:iot_client/services/connection/connection.dart';

abstract class IApiService {
  Future sendRequest(String deviceId, String name, String payload);

  Future setDeviceName(String deviceId, String name);

  Future<Iterable<dynamic>> getDeviceList();

  Future<Iterable<dynamic>> getDeviceStateHistory(String deviceId,
      {DateTime? start, DateTime? end, int? intervalSeconds, int? count});
}

class ApiEndpoints {
  static const String SendRequest = "SendRequest";
  static const String ChangeDeviceName = "ChangeDeviceName";
  static const String GetDeviceList = "GetDeviceList";
  static const String GetDeviceStateHistory = "GetDeviceStateHistory";
}

class ApiService extends IApiService {
  final IConnectionService connectionService;

  ApiService({required this.connectionService});

  @override
  Future sendRequest(String deviceId, String name, String payload) async {
    await connectionService
        .invoke(ApiEndpoints.SendRequest, args: [deviceId, name, payload]);
  }

  @override
  Future setDeviceName(String deviceId, String name) async {
    await connectionService
        .invoke(ApiEndpoints.ChangeDeviceName, args: [deviceId, name]);
  }

  @override
  Future<Iterable<dynamic>> getDeviceList() async {
    var deviceList = await connectionService.invoke(ApiEndpoints.GetDeviceList);
    return deviceList as Iterable<dynamic>;
  }

  @override
  Future<Iterable<dynamic>> getDeviceStateHistory(String deviceId,
      {DateTime? start,
      DateTime? end,
      int? intervalSeconds,
      int? count}) async {
    var deviceList = await connectionService
        .invoke(ApiEndpoints.GetDeviceStateHistory, args: [
      deviceId,
      start?.toIso8601String(),
      end?.toIso8601String(),
      intervalSeconds,
      count
    ]);
    return deviceList as Iterable<dynamic>;
  }
}
