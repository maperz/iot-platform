import 'package:curtains_client/auth/auth-service.dart';
import 'package:curtains_client/connection/address-resolver.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/domain/device/device-service.dart';
import 'package:curtains_client/domain/device/devices-model.dart';
import 'package:curtains_client/ui/account/profile.dart';
import 'package:curtains_client/ui/helper/connection-info-icon.dart';
import 'package:curtains_client/ui/screens/connection-info-screen.dart';
import 'package:curtains_client/ui/screens/main-screen.dart';
import 'package:curtains_client/utils/build-info.dart';
import 'package:curtains_client/utils/platform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = BuildInfo.isRelease() ? Level.INFO : Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}]: ${record.time}: (${record.loggerName}) ${record.message}');
  });

  await Firebase.initializeApp();

  IAuthService authService = new FirebaseAuthService();

  IAddressResolver resolver =
      PlatformInfo.isWeb() ? new WebAddressResolver() : new AddressResolver();

  await resolver.init();

  IConnection connection = new Connection(resolver, authService);
  connection.start();

  IDeviceListService deviceService = new DeviceListService(connection);
  var deviceListModel = new DeviceListModel(deviceService);

  runApp(MultiProvider(providers: [
    Provider(create: (context) => authService),
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

class MyHomePage extends StatelessWidget {
  late final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(this.title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: const ConnectionInfoIcon(),
            tooltip: 'Show connectivity info',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return ConnectionInfoScreen();
                },
              ));
            },
          ),
        )
      ],
    );

    final drawer = Drawer(
      child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Color(0xFF0D47A1), Colors.blue]),
              ),
              child: ProfileDrawerWidget(),
            ),
            ListTile(leading: Icon(Icons.person), title: Text("Profile")),
            AboutListTile(
              icon: Icon(Icons.contact_page),
              child: Text("About"),
              applicationVersion: 'August 2021',
              applicationLegalese: '\u{a9} 2021 maperz',
            )
          ]),
    );

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: MainScreen(),
    );
  }
}
