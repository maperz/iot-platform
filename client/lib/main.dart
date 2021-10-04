import 'package:iot_client/screens/main/main-page.dart';
import 'package:iot_client/services/auth/auth-service.dart';
import 'package:iot_client/services/connection/address-resolver.dart';
import 'package:iot_client/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level =
      Level.ALL; //BuildInfo.isRelease() ? Level.INFO : Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '[${record.level.name}]: ${record.time}: (${record.loggerName}) ${record.message}');
  });

  IAuthService authService = new FirebaseAuthService();
  await authService.init();

  IAddressResolver addressResolver =
      PlatformInfo.isWeb() ? new WebAddressResolver() : new AddressResolver();

  await addressResolver.init();

  runApp(MultiProvider(providers: [
    Provider<IAuthService>(create: (context) => authService),
    Provider<IAddressResolver>(create: (context) => addressResolver),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<IAddressResolver, IAuthService>(
      builder: (context, addressResolver, authService, child) => MaterialApp(
        title: 'Home Controller',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: MainPage(
          addressResolver: addressResolver,
          authService: authService,
        ),
      ),
    );
  }
}
