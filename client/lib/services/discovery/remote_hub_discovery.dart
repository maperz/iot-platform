import 'package:iot_client/models/connection/index.dart';
import 'package:logging/logging.dart';

import 'hub_discovery.dart';

class RemoteHubDiscovery implements HubDiscovery {
  final logger = Logger('RemoteHubDiscovery');

  static const String publicServerProtocol = "https";
  static const String publicServerHost = "iot.perz.cloud";
  static const int? publicServerPort = null;

  /*
  static const String publicServerProtocol = "http";
  static const String publicServerHost = "localhost";
  static const int? publicServerPort = 4000;
  */

  @override
  Stream<HubAddress> getHubAddresses() async* {
    logger.info('Accessing global hub address');
    yield HubAddress(
        publicServerProtocol, publicServerHost, publicServerPort, true);
  }
}
