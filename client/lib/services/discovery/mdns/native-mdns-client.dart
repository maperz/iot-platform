import 'package:flutter_nsd/flutter_nsd.dart';

import 'mdns-client.dart';

class NativeMDNSClient implements IMDNSClient {
  @override
  Future<MDNSResult?> discoverService(String serviceName) async {
    final nativeNsd = FlutterNsd();

    nativeNsd.discoverServices(serviceName);

    try {
      await for (NsdServiceInfo result in nativeNsd.stream) {
        if (result.hostname == null || result.port == null) {
          return null;
        }
        return MDNSResult(result.hostname!, result.port!);
      }
    } on NsdError catch (err) {
      print("NsdError: " + err.errorCode.toString());
    }
  }
}
