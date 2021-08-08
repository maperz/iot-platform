import 'package:curtains_client/connection/signalr/signalr-helper.dart';

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
  final SignalRHelper signalR;

  ApiService({required this.signalR});

  @override
  Future sendRequest(String deviceId, String name, String payload) async {
    await signalR
        .getConnection()
        ?.invoke(ApiEndpoints.SendRequest, args: [deviceId, name, payload]);
  }

  @override
  Future setDeviceName(String deviceId, String name) async {
    await signalR
        .getConnection()
        ?.invoke(ApiEndpoints.ChangeDeviceName, args: [deviceId, name]);
  }

  @override
  Future<Iterable<dynamic>> getDeviceList() async {
    var deviceList = (await signalR
        .getConnection()
        ?.invoke(ApiEndpoints.GetDeviceList)) as Iterable<dynamic>;
    return deviceList;
  }
}
