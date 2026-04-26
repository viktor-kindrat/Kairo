import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/features/auth/repositories/firebase_auth_session.dart';
import 'package:kairo/features/auth/repositories/firebase_email_auth_client.dart';
import 'package:kairo/features/auth/repositories/firebase_google_auth_client.dart';

class FirebaseAuthRepository implements IAuthRepository {
  late final FirebaseEmailAuthClient _emailClient;
  late final FirebaseGoogleAuthClient _googleClient;
  late final FirebaseAuthSession _session;

  FirebaseAuthRepository({
    required LocalUserStore userStore,
    FirebaseAuth? firebaseAuth,
    Connectivity? connectivity,
    GoogleSignIn? googleSignIn,
  }) {
    final resolvedAuth = firebaseAuth ?? FirebaseAuth.instance;
    _session = FirebaseAuthSession(
      connectivity: connectivity ?? Connectivity(),
      firebaseAuth: resolvedAuth,
      userStore: userStore,
    );
    _emailClient = FirebaseEmailAuthClient(
      firebaseAuth: resolvedAuth,
      session: _session,
    );
    _googleClient = FirebaseGoogleAuthClient(
      firebaseAuth: resolvedAuth,
      googleSignIn: googleSignIn ?? GoogleSignIn.instance,
      session: _session,
    );
  }

  @override
  Future<bool> checkEmailVerified() {
    return _session.checkEmailVerified();
  }

  @override
  Future<void> deleteAccount() {
    return _session.deleteAccount();
  }

  @override
  Future<LocalUser?> getCurrentUser() {
    return _session.getCurrentUser();
  }

  @override
  Future<void> sendEmailVerification() {
    return _emailClient.sendEmailVerification();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _emailClient.sendPasswordResetEmail(email);
  }

  @override
  Future<LocalUser> signIn({required String email, required String password}) {
    return _emailClient.signIn(email: email, password: password);
  }

  @override
  Future<LocalUser?> signInWithGoogle() {
    return _googleClient.signIn();
  }

  @override
  Future<void> signOut() async {
    await _emailClient.signOut();
    await _googleClient.signOutIfInitialized();
  }

  @override
  Future<LocalUser> signUp(LocalUser user) {
    return _emailClient.signUp(user);
  }
}
