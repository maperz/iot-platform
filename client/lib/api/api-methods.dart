abstract class ApiMethods {
  Future sendRequest(String deviceId, String name, String payload);

  Future setDeviceName(String deviceId, String name);

  Future<Iterable<dynamic>> getDeviceList();
}
