import 'package:curtains_client/connection/address-resolver.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-service.dart';
import 'package:curtains_client/domain/device/devices-model.dart';
import 'package:curtains_client/ui/screens/connection-info-screen.dart';
import 'package:curtains_client/ui/screens/main-screen.dart';
import 'package:curtains_client/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  IAddressResolver resolver =
      PlatformInfo.isWeb() ? new WebAddressResolver() : new AddressResolver();

  await resolver.init();

  IConnection connection = new Connection(resolver);
  connection.start();

  IDeviceListService deviceService = new DeviceListService(connection);
  var deviceListModel = new DeviceListModel(deviceService);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<Connection>(
      create: (context) => connection as Connection,
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
      title: 'Home Controller',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(key: GlobalKey(), title: 'Home Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showMainScreen = true;

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(widget.title!),
    );

    final bottomBar = Container(
        child: BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => setState(() => _showMainScreen = true),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => setState(() => _showMainScreen = true),
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () => setState(() => _showMainScreen = false),
          ),
        ],
      ),
    ));

    return Scaffold(
      appBar: appBar,
      body: _showMainScreen ? MainScreen() : ConnectionInfoScreen(),
      bottomNavigationBar: bottomBar,
    );
  }
}
