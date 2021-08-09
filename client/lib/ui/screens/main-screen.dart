import 'package:curtains_client/auth/auth-service.dart';
import 'package:curtains_client/connection/address-resolver.dart';
import 'package:curtains_client/connection/connection.dart';
import 'package:curtains_client/ui/account/login-page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../device-list.dart';
import 'connecting-placeholder.dart';

class MainScreenBloc extends StatelessWidget {
  final WidgetBuilder _onAuthorizedPageBuilder;
  final WidgetBuilder _loginPageBuilder;

  const MainScreenBloc(this._onAuthorizedPageBuilder, this._loginPageBuilder,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IAddressResolver>(
        builder: (context, addressResolver, child) =>
            Consumer<IAuthService>(builder: (context, authService, child) {
              var requiresAuthStream = addressResolver
                  .getAddress()
                  .map((address) => address.requiresAuthentication);

              var isAuthenticated = authService.isLoggedIn();

              var showLoginPage = CombineLatestStream.combine2(
                  requiresAuthStream,
                  isAuthenticated,
                  (bool requires, bool isAuth) => (!requires || isAuth));

              return StreamBuilder<bool>(
                  stream: showLoginPage,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    var builder = (snapshot.data!
                        ? this._loginPageBuilder
                        : this._onAuthorizedPageBuilder);

                    return builder(context);
                  });
            }));
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loginPageBuilder = (context) => LoginPage((user) {});
    var authorizedPageBuilder = (context) => Consumer<IConnectionService>(
        builder: (context, connectionService, child) =>
            StreamBuilder<ConnectionStateData>(
                stream: connectionService.getConnectedState(),
                builder: (context, snapshot) {
                  final info = snapshot.data?.info;
                  if (snapshot.hasData && info != null && info.isConnected) {
                    return DeviceListWidget();
                  }
                  return Stack(children: [
                    ConnectingListPlaceholder(info),
                    ConnectingPlaceholder(info)
                  ]);
                }));

    return MainScreenBloc(loginPageBuilder, authorizedPageBuilder);
  }
}
