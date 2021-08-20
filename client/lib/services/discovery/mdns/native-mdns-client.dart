import 'package:flutter_nsd/flutter_nsd.dart';
import 'package:logging/logging.dart';

import 'mdns-client.dart';

class NativeMDNSClient implements IMDNSClient {
  final _logger = new Logger("NativeMDNSClient");

  @override
  Future<MDNSResult?> discoverService(String serviceName) async {
    _logger.info("Running mDNS discovery for '$serviceName'");
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
      _logger.severe("An NsdError occured", err);
    } catch (err) {
      _logger.severe("Error occured during discovery", err);
    }
    return null;
  }
}
