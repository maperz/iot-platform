import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/hub-discovery.dart';

class RemoteHubDiscovery implements HubDiscovery {
  static const String PUBLIC_SERVER_PROTOCOL = "https";
  static const String PUBLIC_SERVER_HOST = "iot.perz.cloud";
  static const int? PUBLIC_SERVER_PORT = null;

  @override
  Stream<HubAddress> getHubAddresses() async* {
    print("Accessing global hub address");
    yield new HubAddress(
        PUBLIC_SERVER_PROTOCOL, PUBLIC_SERVER_HOST, PUBLIC_SERVER_PORT);
  }
}
