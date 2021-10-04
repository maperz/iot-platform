import 'package:iot_client/screens/login/components/login-form.dart';
import 'package:iot_client/services/auth/auth-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef LoggedInCallback = Function(User);

class LoginPage extends StatelessWidget {
  final LoggedInCallback loggedInCallback;

  const LoginPage({required this.loggedInCallback, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IAuthService>(
      builder: (context, authService, child) => Scaffold(
          /*appBar: AppBar(
            title: Text(_getAppTitle(context)),
          ),*/
          body: Padding(
              padding: EdgeInsets.all(10),
              child: LoginForm(
                  loginCallback: (email, password) =>
                      _onLogin(email, password, authService)))),
    );
  }

  _onLogin(String email, String password, IAuthService authService) async {
    var result = await authService.login(email, password);

    if (result != null) {
      this.loggedInCallback(result);
    }
  }
}
