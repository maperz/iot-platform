import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:rxdart/rxdart.dart';

abstract class IAuthService {
  Future<User?> login(String email, String password);
  Future logout();
  Future init();

  Stream<bool> isLoggedIn();
  Stream<User?> currentUser();
  Future<User?> getUser();
}

class FirebaseAuthService extends IAuthService {
  late FirebaseAuth _auth;
  late BehaviorSubject<User?> _userStream;

  @override
  Stream<User?> currentUser() {
    return _userStream.distinct();
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
    _userStream.add(user);
    return user;
  }

  @override
  Future logout() {
    return _auth.signOut();
  }

  @override
  Future<User?> getUser() async {
    return _auth.currentUser;
  }

  @override
  Future init() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _userStream = new BehaviorSubject.seeded(_auth.currentUser);

    _auth.idTokenChanges().listen((user) {
      _userStream.add(user);
    });
  }
}
