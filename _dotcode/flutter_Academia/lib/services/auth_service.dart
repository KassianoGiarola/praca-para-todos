import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  static const _explicitLoginKey = 'auth.explicit_login_selected';

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> configurePersistence() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  Future<bool> hasExplicitLogin() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_explicitLoginKey) ?? false;
  }

  Future<void> markExplicitLogin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_explicitLoginKey, true);
  }

  Future<void> clearExplicitLogin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_explicitLoginKey);
  }

  Future<UserCredential> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    await markExplicitLogin();
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    await markExplicitLogin();
    return credential;
  }

  Future<UserCredential> linkCurrentUserWithGoogle() async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    final credential = kIsWeb
        ? await user.linkWithPopup(provider)
        : await user.linkWithProvider(provider);

    await markExplicitLogin();
    return credential;
  }

  Future<void> signOut() async {
    Object? signOutError;
    StackTrace? signOutStackTrace;

    try {
      await _auth.signOut();
    } on Object catch (error, stackTrace) {
      signOutError = error;
      signOutStackTrace = stackTrace;
    }

    try {
      await clearExplicitLogin();
    } on Object catch (error) {
      debugPrint('Não foi possível limpar o marcador local de login: $error');
    }

    if (signOutError != null) {
      Error.throwWithStackTrace(signOutError, signOutStackTrace!);
    }
  }

  Future<String> requireUserId() async {
    final existingUser = currentUser;
    if (existingUser != null) {
      return existingUser.uid;
    }

    throw StateError('Usuário não autenticado.');
  }
}
