import 'package:iot_client/screens/connection-info/connection_info_page.dart';
import 'package:iot_client/screens/device-list/device_list_page.dart';
import 'package:iot_client/services/api/api_service.dart';
import 'package:iot_client/services/auth/auth_service.dart';
import 'package:iot_client/services/connection/address_resolver.dart';
import 'package:iot_client/services/connection/connection.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/account/profile.dart';
import 'components/helper/connection_info_icon.dart';

class MainScreen extends StatefulWidget {
  final IAddressResolver addressResolver;
  final IAuthService authService;
  const MainScreen(
      {required this.addressResolver, required this.authService, Key? key})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      title: const Text("Home Controller"),
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
                    LinearGradient(colors: [Color(0xFF0D47A1), Colors.blue]),
              ),
              child: ProfileDrawerWidget(),
            ),
            ListTile(leading: Icon(Icons.person), title: Text("Profile")),
            AboutListTile(
              icon: Icon(Icons.contact_page),
              applicationVersion: 'August 2021',
              applicationLegalese: '\u{a9} 2021 maperz',
              child: Text("About"),
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
          body: const DeviceListPage(),
        ));
  }
}
