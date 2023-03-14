import 'package:flutter/material.dart';

typedef OnLoginCallback = void Function(String email, String password);
typedef OnRegisterCallback = void Function(
    String username, String email, String password);

class LoginOrRegisterForm extends StatefulWidget {
  final OnLoginCallback loginCallback;
  final OnRegisterCallback registerCallback;

  const LoginOrRegisterForm(
      {required this.loginCallback, required this.registerCallback, Key? key})
      : super(key: key);

  @override
  _LoginOrRegisterFormState createState() => _LoginOrRegisterFormState();
}

class _LoginOrRegisterFormState extends State<LoginOrRegisterForm> {
  var isLogin = true;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Text(isLogin ? 'Login Account' : "Register Account",
                style: Theme.of(context).textTheme.headlineSmall)),
        if (!isLogin)
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.name,
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: "Example Name",
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(10),
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: const InputDecoration(
              hintText: "example@email.com",
              border: OutlineInputBorder(),
              labelText: 'Email',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: const InputDecoration(
              hintText: "Secret password",
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
            onSubmitted: (value) {
              widget.loginCallback(
                  emailController.text, passwordController.text);
            },
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Text(isLogin ? 'Login' : 'Create Account'),
                onPressed: () {
                  final email = emailController.text;
                  final password = passwordController.text;

                  passwordController.clear();

                  if (email.isEmpty || password.isEmpty) {
                    return;
                  }

                  if (isLogin) {
                    widget.loginCallback(email, password);
                  } else {
                    final username = usernameController.text;
                    widget.registerCallback(username, email, password);
                  }
                })),
        const SizedBox(
          height: 12,
        ),
        TextButton(
            onPressed: _toggleLoginRegisterView,
            child: Text(isLogin
                ? 'No account yet? - Click to register'
                : 'Already have an account - Login here'))
      ],
    );
  }

  _toggleLoginRegisterView() {
    passwordController.clear();

    setState(() {
      isLogin = !isLogin;
    });
  }
}
