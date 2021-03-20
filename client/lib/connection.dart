import 'package:curtains_client/api/api-methods.dart';
import 'package:signalr_core/signalr_core.dart';

class Connection implements ApiMethods {
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

    await _connection?.start();
  }

  @override
  Future setSpeed(double speed) async {
    if (_connection == null) {
      return;
    }

    await _connection?.send(methodName: "SetSpeed", args: [speed]);
  }
}
