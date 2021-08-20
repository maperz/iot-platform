import 'package:curtains_client/screens/device-list/components/connection-placeholder/connection-placeholder-page.dart';
import 'package:curtains_client/screens/device-list/device-list-page.dart';
import 'package:curtains_client/screens/login/login-page.dart';
import 'package:curtains_client/screens/main/bloc/authentication_bloc.dart';
import 'package:curtains_client/services/auth/auth-service.dart';
import 'package:curtains_client/services/connection/address-resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
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
            return DeviceListPage();
          }

          if (state is InitialAuthenticationState) {
            return ConnectionPlaceholderPage(
              alternativeStatus: "Determining Authentication",
            );
          }
          return Container();
        },
      );
    });
  }
}
