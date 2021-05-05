import 'package:curtains_client/connection/address-resolver.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/ui/device-list.dart';
import 'package:curtains_client/domain/device/device-service.dart';
import 'package:curtains_client/domain/device/devices-model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Connection> createAndStartConnection() async {
  IAddressResolver resolver = new AddressResolver();
  IConnection connection = new Connection(resolver);
  connection.start();
  return connection;
}

void main() async {
  IConnection connection = await createAndStartConnection();
  IDeviceListService deviceService = new DeviceListService(connection);
  var deviceListModel = new DeviceListModel(deviceService);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<Connection>(
      create: (context) => connection,
    ),
    ChangeNotifierProvider<DeviceListModel>(
      create: (context) => deviceListModel,
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Things',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(key: GlobalKey(), title: 'Smart Things'),
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
    final appBar = AppBar(
      title: Text(widget.title),
    );

    final bottomBar = Container(
        height: 50,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.analytics),
                onPressed: () {},
              ),
            ],
          ),
        ));

    return Scaffold(
      appBar: appBar,
      body: Consumer<Connection>(builder: (context, connection, child) {
        return StreamBuilder<bool>(
          stream: connection.getConnectedState(),
          builder: (context, connected) {
            if (connected.hasData && connected.data) {
              return DeviceListWidget();
            }

            return StreamBuilder(
                stream: connection.getConnectionAddress(),
                builder: (context, address) {
                  return ConnectingPlaceholder(
                      address.hasData ? address.data : null);
                });
          },
        );
      }),
      bottomNavigationBar: bottomBar,
    );
  }
}

class ConnectingPlaceholder extends StatelessWidget {
  final String address;
  ConnectingPlaceholder(this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 6,
              ),
            ),
            Text(
              address != null ? "Establishing connection" : "Discovering Hub",
              style: Theme.of(context).textTheme.headline5,
            ),
            if (address != null)
              Text(
                'Connecting to Hub at $address',
                style: Theme.of(context).textTheme.caption,
              )
          ],
        ),
      ),
    );
  }
}
