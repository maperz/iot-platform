import 'package:flutter/material.dart';

typedef OnLoginCallback = void Function(String email, String password);

class LoginForm extends StatefulWidget {
  final OnLoginCallback loginCallback;

  const LoginForm({required this.loginCallback, Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text('Login', style: Theme.of(context).textTheme.headline5)),
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
              widget.loginCallback(
                  emailController.text, passwordController.text);
            },
          ),
        ),
        Container(
            height: 60,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text('Login'),
              onPressed: () {
                widget.loginCallback(
                    emailController.text, passwordController.text);
              },
            )),
      ],
    );
  }
}
