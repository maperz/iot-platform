import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<User?> login(String email, String password);
  Future logout();

  Stream<bool> isLoggedIn();
  Stream<User?> currentUser();
  Future<User?> getUser();
}

class FirebaseAuthService extends IAuthService {
  late FirebaseAuth _auth;

  FirebaseAuthService() {
    _auth = FirebaseAuth.instance;
  }

  @override
  Stream<User?> currentUser() {
    return _auth.userChanges();
  }

  @override
  Stream<bool> isLoggedIn() {
    return currentUser().map((user) => user != null);
  }

  @override
  Future<User?> login(String email, String password) async {
    var response = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return response.user;
  }

  @override
  Future logout() {
    return _auth.signOut();
  }

  @override
  Future<User?> getUser() async {
    return _auth.currentUser;
  }
}
