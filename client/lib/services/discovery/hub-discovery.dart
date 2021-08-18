import '../../models/connection/models/hub-address.dart';

abstract class HubDiscovery {
  Stream<HubAddress> getHubAddresses();
}
