import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:rxdart/rxdart.dart';

abstract class IAuthService {
  Future<User?> login(String email, String password);
  Future logout();
  Future init();

  Stream<bool> isLoggedIn();
  Stream<User?> currentUser();
}

class FirebaseAuthService extends IAuthService {
  late FirebaseAuth _auth;
  late BehaviorSubject<User?> _userStream;

  @override
  Stream<User?> currentUser() {
    return _auth.idTokenChanges();
  }

  @override
  Stream<bool> isLoggedIn() {
    return currentUser().map((user) => user != null);
  }

  @override
  Future<User?> login(String email, String password) async {
    var response = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    var user = response.user;
    return user;
  }

  @override
  Future logout() {
    return _auth.signOut();
  }

  @override
  Future init() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
  }
}
