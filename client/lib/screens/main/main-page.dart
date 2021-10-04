import 'package:iot_client/screens/connection-info/connection-info-page.dart';
import 'package:iot_client/services/api/api-service.dart';
import 'package:iot_client/services/auth/auth-service.dart';
import 'package:iot_client/services/connection/address-resolver.dart';
import 'package:iot_client/services/connection/connection.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/account/profile.dart';
import 'components/helper/connection-info-icon.dart';
import 'main-screen.dart';

class MainPage extends StatefulWidget {
  final IAddressResolver addressResolver;
  final IAuthService authService;
  const MainPage(
      {required this.addressResolver, required this.authService, Key? key})
      : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late IConnectionService connectionService;
  late IApiService apiService;

  @override
  void initState() {
    super.initState();
    connectionService = ConnectionService(
        addressResolver: widget.addressResolver,
        authService: widget.authService);
    connectionService.start();

    apiService = ApiService(connectionService: connectionService);
  }

  @override
  void dispose() {
    connectionService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text("Home Controller"),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: ConnectionInfoIcon(connectionService: connectionService),
            tooltip: 'Show connectivity info',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return ConnectionInfoPage(
                    connectionService: connectionService,
                  );
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
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: const [Color(0xFF0D47A1), Colors.blue]),
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

    return MultiProvider(
        providers: [
          Provider<IConnectionService>(create: (context) => connectionService),
          Provider<IApiService>(create: (context) => apiService)
        ],
        child: Scaffold(
          appBar: appBar,
          drawer: drawer,
          body: MainScreen(),
        ));
  }
}
