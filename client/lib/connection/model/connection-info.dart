class ConnectionInfo {
  String targetAddress;
  bool isConnected;
  bool isProxy;
  String? proxiedAddress;
  String version;

  ConnectionInfo(this.targetAddress, this.isConnected, this.isProxy,
      this.proxiedAddress, this.version);

  factory ConnectionInfo.fromJson(
      String targetAddress, Map<String, dynamic> json) {
    var isConnected = json['isConnected'];
    var isProxy = json['isProxy'];
    var proxiedAddress = json['proxiedAddress'];
    var version = json['version'];

    return ConnectionInfo(
        targetAddress, isConnected, isProxy, proxiedAddress, version);
  }
}
