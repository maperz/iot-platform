import 'package:logging/logging.dart';
import 'package:signalr_core/signalr_core.dart';

import 'retry_policy.dart';

class SignalRHelper {
  HubConnection? _connection;

  final Logger logger = Logger("SignalR");
  final void Function(Exception?) onReconnecting;
  final void Function(String?) onReconnected;

  SignalRHelper({required this.onReconnecting, required this.onReconnected});

  Future init(String hubUrl, String? token) async {
    assert(_connection == null ||
        _connection!.state == HubConnectionState.disconnected);

    var accessTokenFactory = (token != null)
        ? () {
            return Future.value(token);
          }
        : null;

    final options =
        HttpConnectionOptions(accessTokenFactory: accessTokenFactory);

    var retryPolicy = IntervalRetryPolicy([
      const Duration(seconds: 1),
      const Duration(seconds: 3),
      const Duration(seconds: 7),
      const Duration(seconds: 10),
      const Duration(seconds: 15),
    ]);

    var connection = HubConnectionBuilder()
        .withUrl(hubUrl, options)
        .withHubProtocol(JsonHubProtocol())
        .withAutomaticReconnect(retryPolicy)
        .build();

    _connection = connection;

    connection.onreconnecting((error) {
      logger.warning(error != null
          ? 'An error occured during connection, Trying to reconnect ... [Err=$error]'
          : 'Connection closed, trying to reconnect ...');

      onReconnecting(error);
    });

    connection.onreconnected((connectionId) {
      logger.info("Reconnected successfully with new id $connectionId");
      onReconnected(connectionId);
    });

    connection.onclose((error) {
      logger.log(
          error != null ? Level.SEVERE : Level.INFO,
          error != null
              ? 'Connection closed with error: ${error.toString()}'
              : 'Connection closed');
    });

    logger
        .fine("Created connection instance pointing to ${connection.baseUrl}");
  }

  Future start() async {
    var connection = _connection;
    if (connection == null) {
      throw Exception("Can not start SignalR Helper without calling init");
    }

    logger.info("Starting connection to ${connection.baseUrl}");
    await connection.start();
    logger.info("Connection established to ${connection.baseUrl}");
  }

  Future stop() async {
    var connection = _connection;
    if (connection == null) {
      return;
    }

    if (connection.state != HubConnectionState.disconnected &&
        connection.state != HubConnectionState.disconnecting) {
      await connection.stop();
      logger.info("Connection stopped");
    }
  }

  HubConnection? getConnection() => _connection;
}
