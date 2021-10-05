import '../../models/connection/models/hub_address.dart';

abstract class HubDiscovery {
  Stream<HubAddress> getHubAddresses();
}
