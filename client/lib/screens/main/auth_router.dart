import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_client/screens/device-list/components/connection-placeholder/connection_placeholder_page.dart';
import 'package:iot_client/screens/login/login_page.dart';
import 'package:iot_client/screens/main/main_screen.dart';
import 'package:iot_client/services/auth/auth_service.dart';
import 'package:iot_client/services/connection/address_resolver.dart';

import 'bloc/authentication_bloc.dart';

class AuthRouter extends StatelessWidget {
  final IAddressResolver addressResolver;
  final IAuthService authService;

  const AuthRouter(
      {required this.addressResolver, required this.authService, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authBloc = AuthenticationBloc(
        addressResolver: addressResolver, authService: authService);

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      bloc: authBloc,
      builder: (context, state) {
        if (state is ShowLoginScreen) {
          return LoginPage(loggedInCallback: (user) {});
        }
        if (state is ShowMainScreen) {
          return MainScreen(
            addressResolver: addressResolver,
            authService: authService,
          );
        }

        if (state is InitialAuthenticationState) {
          return const ConnectionPlaceholderPage(
            alternativeStatus: "Determining authentication status",
          );
        }
        return Container();
      },
    );
  }
}
