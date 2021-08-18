import 'package:curtains_client/screens/login/login-page.dart';
import 'package:curtains_client/services/auth/auth-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDrawerWidget extends StatelessWidget {
  const ProfileDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<IAuthService>(
        builder: (context, authService, child) => StreamBuilder<User?>(
            stream: authService.currentUser(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return _buildDrawer(context, authService, user);
            }));
  }

  Widget _buildDrawer(
      BuildContext context, IAuthService authService, User? user) {
    if (user == null) {
      return TextButton(
          onPressed: () {
            _tryPop(context);
            Navigator.push(context, MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return LoginPage(
                    loggedInCallback: (user) => _onLoggedIn(context, user));
              },
            ));
          },
          child: Text("Login"));
    }

    var userImage = user.photoURL;
    return Column(
      children: [
        userImage != null
            ? CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(userImage),
              )
            : CircleAvatar(
                radius: 40,
                backgroundColor: Colors.brown.shade800,
                child: Text(user.displayName ?? ""),
              ),
        Container(
          height: 10,
        ),
        Text(
          user.displayName ?? "",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () async {
              await authService.logout();
              _tryPop(context);
            },
            child: Text("Logout"))
      ],
    );
  }

  _onLoggedIn(BuildContext context, User user) {
    _tryPop(context);
  }

  _tryPop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
