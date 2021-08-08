import 'package:curtains_client/auth/auth-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _State createState() => _State();

  Function(User) loginCallback;

  LoginPage(this.loginCallback);
}

class _State extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<IAuthService>(
      builder: (context, authService, child) => Scaffold(
          /*appBar: AppBar(
            title: Text(_getAppTitle(context)),
          ),*/
          body: Padding(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text('Login',
                          style: Theme.of(context).textTheme.headline5)),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      onSubmitted: (value) {
                        _onLogin(context, authService);
                      },
                    ),
                  ),
                  Container(
                      height: 60,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        child: Text('Login'),
                        onPressed: () {
                          _onLogin(context, authService);
                        },
                      )),
                ],
              ))),
    );
  }

  _onLogin(BuildContext context, IAuthService auth) async {
    final email = emailController.text;
    final password = passwordController.text;
    var result = await auth.login(email, password);

    if (result != null) {
      this.widget.loginCallback(result);
    }
  }

  String _getAppTitle(BuildContext context) {
    final Title? ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
    return ancestorTitle?.title ?? "";
  }
}
