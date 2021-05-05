import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/local-hub-discovery.dart';
import 'package:curtains_client/discovery/remote-hub-discovery.dart';

abstract class IAddressResolver {
  Stream<String> getHubUrl();
}

class AddressResolver implements IAddressResolver {
  final localDiscovery = new LocalHubDiscovery();
  final remoteDiscovery = new RemoteHubDiscovery();

  @override
  Stream<String> getHubUrl() {
    return _getHubAddress().map((address) => address.toString());
  }

  Stream<HubAddress> _getHubAddress() async* {
    yield* localDiscovery.getHubAddresses();
    // yield* remoteDiscovery.getHubAddresses();
  }
}
