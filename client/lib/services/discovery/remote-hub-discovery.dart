import 'package:iot_client/models/connection/index.dart';
import 'package:logging/logging.dart';

import 'hub-discovery.dart';

class RemoteHubDiscovery implements HubDiscovery {
  final logger = Logger('RemoteHubDiscovery');

  static const String PUBLIC_SERVER_PROTOCOL = "https";
  static const String PUBLIC_SERVER_HOST = "iot.perz.cloud";
  static const int? PUBLIC_SERVER_PORT = null;

  /*
  static const String PUBLIC_SERVER_PROTOCOL = "http";
  static const String PUBLIC_SERVER_HOST = "localhost";
  static const int? PUBLIC_SERVER_PORT = 4000;
  */

  @override
  Stream<HubAddress> getHubAddresses() async* {
    logger.info('Accessing global hub address');
    yield HubAddress(
        PUBLIC_SERVER_PROTOCOL, PUBLIC_SERVER_HOST, PUBLIC_SERVER_PORT, true);
  }
}
