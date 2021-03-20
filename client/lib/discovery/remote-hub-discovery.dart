import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/hub-discovery.dart';

class RemoteHubDiscovery implements HubDiscovery {
  static const String PUBLIC_SERVER_PROTOCOL = "http";
  static const String PUBLIC_SERVER_HOST = "localhost";
  static const int PUBLIC_SERVER_PORT = 4000;

  @override
  Stream<HubAddress> getHubAddresses() async* {
    print("Accessing global hub address");
    yield new HubAddress(
        PUBLIC_SERVER_PROTOCOL, PUBLIC_SERVER_HOST, PUBLIC_SERVER_PORT);
  }
}
