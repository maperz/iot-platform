import 'package:curtains_client/services/connection/connection.dart';

abstract class IApiService {
  Future sendRequest(String deviceId, String name, String payload);

  Future setDeviceName(String deviceId, String name);

  Future<Iterable<dynamic>> getDeviceList();
}

class ApiEndpoints {
  static const String SendRequest = "SendRequest";
  static const String ChangeDeviceName = "ChangeDeviceName";
  static const String GetDeviceList = "GetDeviceList";
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
}
