import 'package:curtains_client/connection/signalr/retry-policy.dart';
import 'package:logging/logging.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRHelper {
  HubConnection? _connection;

  final Logger logger = Logger("SignalR");
  final void Function(Exception?) onReconnect;
  final void Function(String?) onReconnected;

  SignalRHelper({required this.onReconnect, required this.onReconnected});

  Future init(String hubUrl, String? token) async {
    assert(_connection == null ||
        _connection!.state == HubConnectionState.disconnected);

    var accessTokenFactory = (token != null)
        ? () {
            return Future.value(token);
          }
        : null;

    final options = new HttpConnectionOptions(
        // Workaround to fix a bug that
        //ly happens when connecting
        // to the server
        transport: hubUrl.contains("iot.perz.cloud")
            ? HttpTransportType.longPolling
            : HttpTransportType.webSockets,
        //logging: (level, message) => print(message)
        accessTokenFactory: accessTokenFactory);

    var retryPolicy = new IntervalRetryPolicy([
      Duration(seconds: 1),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 15),
      Duration(seconds: 15),
      Duration(seconds: 30),
    ]);

    var connection = HubConnectionBuilder()
        .withUrl(hubUrl, options)
        .withHubProtocol(JsonHubProtocol())
        .withAutomaticReconnect(retryPolicy)
        .build();

    _connection = connection;

    connection.onreconnecting((error) {
      logger.severe(
          error != null ? 'Reconnecting with error' : 'Reconnecting ...',
          error);

      onReconnect(error);
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

    logger.fine("Starting connection to ${connection.baseUrl}");
    await connection.start();
    logger.fine("Connection established to ${connection.baseUrl}");
  }

  Future stop() async {
    var connection = _connection;
    if (connection == null) {
      return;
    }

    if (connection.state != HubConnectionState.disconnected &&
        connection.state != HubConnectionState.disconnecting) {
      await connection.stop();
      logger.fine("Connection stopped");
    }
  }

  HubConnection? getConnection() => this._connection;
}
