abstract class ApiMethods {
  // Stream<String> GetConnectedDevices();

  Future setSpeed(String deviceId, double speed);

  Future setDeviceName(String deviceId, String name);

  Future getDeviceList();
}
