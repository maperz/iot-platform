class HubAddress {
  final String protocol;
  final String host;
  final int? port;
  final bool requiresAuthentication;

  HubAddress(this.protocol, this.host, this.port, this.requiresAuthentication);

  @override
  String toString() {
    if (port == null) {
      return '$protocol://$host';
    }

    return '$protocol://$host:$port';
  }
}
