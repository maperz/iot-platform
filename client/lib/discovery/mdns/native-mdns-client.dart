import 'package:curtains_client/discovery/mdns/mdns-client.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nsd/flutter_nsd.dart';

class NativeMDNSClient implements IMDNSClient {
  @override
  Future<MDNSResult?> discoverService(String serviceName) async {
    final nativeNsd = FlutterNsd();

    nativeNsd.discoverServices(serviceName);

    await for (NsdServiceInfo result in nativeNsd.stream) {
      if (result.hostname == null || result.port == null) {
        return null;
      }
      return MDNSResult(result.hostname!, result.port!);
    }
  }
}
