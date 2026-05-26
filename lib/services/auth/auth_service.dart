import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/firebase_auth_config.dart';
import '../../models/app_user.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email'],
              serverClientId: FirebaseAuthConfig.googleWebClientId,
            );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  AppUser _mapFirebaseUser(User user) {
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
      signInMethod: isGoogle ? SignInMethod.google : SignInMethod.email,
    );
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Please fill all fields.');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapFirebaseUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  Future<AppUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().length < 2) {
      throw AuthException('Please enter your full name.');
    }
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Please fill all fields.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      return _mapFirebaseUser(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authData = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authData.accessToken,
        idToken: authData.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      return _mapFirebaseUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyAuthError(e));
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? e.code;
    }
  }
}
