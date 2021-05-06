abstract class ApiMethods {
  Future setSpeed(String deviceId, double speed);

  Future setDeviceName(String deviceId, String name);

  Future getDeviceList();
}
