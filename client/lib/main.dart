import 'package:curtains_client/screens/home/components/account/profile.dart';
import 'package:curtains_client/screens/home/components/helper/connection-info-icon.dart';
import 'package:curtains_client/services/api/api-service.dart';
import 'package:curtains_client/services/auth/auth-service.dart';
import 'package:curtains_client/services/connection/address-resolver.dart';
import 'package:curtains_client/services/connection/connection.dart';
import 'package:curtains_client/services/device/device-service.dart';
import 'package:curtains_client/services/device/devices-model.dart';
import 'package:curtains_client/screens/connection-info/connection-info-page.dart';
import 'package:curtains_client/screens/home/main-screen.dart';
import 'package:curtains_client/utils/index.dart';
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

  IAuthService authService = new FirebaseAuthService();
  await authService.init();

  IAddressResolver addressResolver =
      PlatformInfo.isWeb() ? new WebAddressResolver() : new AddressResolver();

  await addressResolver.init();

  ConnectionService connectionService = new ConnectionService(
      addressResolver: addressResolver, authService: authService);

  connectionService.init();

  IApiService apiService = new ApiService(connectionService: connectionService);

  runApp(MultiProvider(providers: [
    Provider<IAuthService>(create: (context) => authService),
    Provider<IAddressResolver>(create: (context) => addressResolver),
    Provider<IApiService>(create: (context) => apiService),
    Provider<IConnectionService>(
      create: (context) => connectionService,
    ),
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
                  return ConnectionInfoPage();
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
