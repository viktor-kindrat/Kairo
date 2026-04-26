import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/auth/repositories/firebase_auth_session.dart';
import 'package:kairo/features/auth/utils/firebase_auth_error_mapper.dart';

class FirebaseGoogleAuthClient {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuthSession _session;
  Future<void>? _initialization;

  FirebaseGoogleAuthClient({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseAuthSession session,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _session = session;

  Future<LocalUser?> signIn() async {
    await _session.ensureConnection();
    await _initialize();

    try {
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw const AuthException(
          'Google sign-in did not return a valid identity token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException(
          'We could not complete Google sign in. Please try again.',
        );
      }

      return _session.persistAuthenticatedUser(firebaseUser);
    } on GoogleSignInException catch (error) {
      return _mapGoogleException(error);
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> signOutIfInitialized() async {
    if (_initialization != null) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> _initialize() {
    return _initialization ??= _googleSignIn.initialize();
  }

  LocalUser? _mapGoogleException(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return null;
      case GoogleSignInExceptionCode.uiUnavailable:
        throw const AuthException(
          'Google sign-in is unavailable on this device right now.',
        );
      default:
        throw AuthException(
          error.description ?? 'Google sign-in failed. Please try again.',
        );
    }
  }
}
