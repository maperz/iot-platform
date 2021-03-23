import 'package:curtains_client/connection.dart';
import 'package:curtains_client/devicelist.dart';
import 'package:curtains_client/discovery/hub-address.dart';
import 'package:curtains_client/discovery/local-hub-discovery.dart';
import 'package:curtains_client/discovery/remote-hub-discovery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

var localDiscovery = new LocalHubDiscovery();
var remoteDiscovery = new RemoteHubDiscovery();
Stream<HubAddress> getHubAddress() async* {
  yield* localDiscovery.getHubAddresses();
  yield* remoteDiscovery.getHubAddresses();
}

Future<Connection> createAndStartConnection() async {
  Connection connection = new Connection();
  var addressStream = getHubAddress();
  await for (var address in addressStream) {
    try {
      var hubAddress = address.toString();
      print("Found address at: " + hubAddress);
      await connection.start(hubAddress);
      print("Successfully started connection");
      break;
    } catch (e) {
      print(e);
    }
  }
  return connection;
}

void main() async {
  var connection = await createAndStartConnection();
  runApp(
      ChangeNotifierProvider(create: (context) => connection, child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curtains',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(key: GlobalKey(), title: 'Curtains'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Consumer<Connection>(builder: (context, connection, child) {
          if (!connection.isConnected()) return ConnectingPlaceholder();
          return DeviceListWidget();
        }));
  }
}

// TODO: Give some information on what is happening.. Host address etc..
class ConnectingPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
