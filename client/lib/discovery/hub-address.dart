class HubAddress {
  final String protocol;
  final String host;
  final int? port;
  HubAddress(this.protocol, this.host, this.port);

  @override
  String toString() {
    if (port == null) {
      return '$protocol://$host';
    }

    return '$protocol://$host:$port';
  }
}
