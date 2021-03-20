import 'package:curtains_client/discovery/hub-address.dart';

abstract class HubDiscovery {
  Stream<HubAddress> getHubAddresses();
}
