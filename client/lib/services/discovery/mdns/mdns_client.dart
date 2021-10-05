class MDNSResult {
  String address;
  int port;
  MDNSResult(this.address, this.port);
}

abstract class IMDNSClient {
  Future<MDNSResult?> discoverService(String serviceName);
}
