import 'package:iot_client/screens/login/components/login_form.dart';
import 'package:iot_client/services/auth/auth_service.dart';
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
                body: Scaffold(
              body: Center(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: LoginOrRegisterForm(
                        loginCallback: (email, password) =>
                            _onLogin(email, password, authService, context),
                        registerCallback: (username, email, password) =>
                            _onRegister(username, email, password, authService,
                                context),
                      ),
                    )),
              ),
            )));
  }

  _onLogin(String email, String password, IAuthService authService,
      BuildContext context) async {
    try {
      var result = await authService.login(email, password);
      if (result != null) {
        loggedInCallback(result);
      }
    } on FirebaseAuthException catch (error) {
      _onError(
          error.message ??
              "Failed to login. Invalid username or password combination.",
          context);
    }
  }

  _onRegister(String username, String email, String password,
      IAuthService authService, BuildContext context) async {
    try {
      var result = await authService.register(username, email, password);
      if (result != null) {
        loggedInCallback(result);
      }
    } on FirebaseAuthException catch (error) {
      _onError(
          error.message ??
              "Failed to register user. Maybe a user with this email already exists.",
          context);
    }
  }

  _onError(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
