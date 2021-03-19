import 'package:signalr_core/signalr_core.dart';

class Connection {
  HubConnection _connection;

  Future<void> start(String hubAddress) async {
    print("Starting connection");
    _connection = HubConnectionBuilder()
        .withUrl(hubAddress + '/hub')
        .withAutomaticReconnect()
        .build();

    _connection?.onreconnected((connectionId) {
      print("Reconnected");
    });

    _connection?.on('Test', (message) {
      print("Received message: " + message.toString());
    });

    _connection?.onclose((error) => print("Connection Closed"));

    try {
      await _connection?.start();
    } on Error catch (err) {
      print(err.stackTrace.toString());
    }
  }

  Future sendSpeed(double speed) async {
    if (_connection == null) {
      return;
    }

    await _connection?.send(methodName: "SetSpeed", args: [speed]);
  }
}
