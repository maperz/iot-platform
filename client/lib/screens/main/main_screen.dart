import 'package:iot_client/screens/device-list/components/connection-placeholder/connection_placeholder_page.dart';
import 'package:iot_client/screens/device-list/device_list_page.dart';
import 'package:iot_client/screens/login/login_page.dart';
import 'package:iot_client/screens/main/bloc/authentication_bloc.dart';
import 'package:iot_client/services/auth/auth_service.dart';
import 'package:iot_client/services/connection/address_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<IAddressResolver, IAuthService>(
        builder: (context, addressResolver, authService, child) {
      var authBloc = AuthenticationBloc(
          addressResolver: addressResolver, authService: authService);
      return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        bloc: authBloc,
        builder: (context, state) {
          if (state is ShowLoginScreen) {
            return LoginPage(loggedInCallback: (user) {});
          }
          if (state is ShowDeviceListScreen) {
            return const DeviceListPage();
          }

          if (state is InitialAuthenticationState) {
            return const ConnectionPlaceholderPage(
              alternativeStatus: "Determining authentication status",
            );
          }
          return Container();
        },
      );
    });
  }
}
