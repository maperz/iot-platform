class ConnectionInfo {
  bool isConnected;
  bool isProxy;
  String targetAddress;
  String? proxiedAddress;
  String? hubId;
  String version;

  ConnectionInfo(
      {required this.targetAddress,
      required this.isConnected,
      required this.isProxy,
      this.hubId,
      this.proxiedAddress,
      required this.version});

  factory ConnectionInfo.fromJson(
      String targetAddress, Map<String, dynamic> json) {
    var isConnected = json['isConnected'];
    var isProxy = json['isProxy'];
    var hubId = json['hubId'];
    var proxiedAddress = json['proxiedAddress'];
    var version = json['version'];

    return ConnectionInfo(
        targetAddress: targetAddress,
        isConnected: isConnected,
        isProxy: isProxy,
        proxiedAddress: proxiedAddress,
        version: version,
        hubId: hubId);
  }
}
