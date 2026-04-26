import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/features/auth/repositories/firebase_auth_session.dart';
import 'package:kairo/features/auth/utils/firebase_auth_error_mapper.dart';

class FirebaseEmailAuthClient {
  final FirebaseAuth _firebaseAuth;
  final FirebaseAuthSession _session;

  const FirebaseEmailAuthClient({
    required FirebaseAuth firebaseAuth,
    required FirebaseAuthSession session,
  }) : _firebaseAuth = firebaseAuth,
       _session = session;

  Future<void> sendEmailVerification() async {
    await _session.ensureConnection();

    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw const AuthException(
          'Please create an account or log in before requesting '
          'email verification.',
        );
      }

      await currentUser.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _session.ensureConnection();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: normalizeEmail(email));
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    await _session.ensureConnection();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizeEmail(email),
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const AuthException('We could not complete sign in. Try again.');
      }

      if (!firebaseUser.emailVerified) {
        await _rejectUnverifiedUser(firebaseUser);
      }

      return _session.persistAuthenticatedUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> signOut() async {
    await _session.ensureConnection();

    try {
      await _firebaseAuth.signOut();
      await _session.clearStoredUser();
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<LocalUser> signUp(LocalUser user) async {
    await _session.ensureConnection();

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizeEmail(user.email),
        password: user.password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw const AuthException(
          'We could not create your account. Please try again.',
        );
      }

      if (user.fullName.trim().isNotEmpty) {
        await firebaseUser.updateDisplayName(user.fullName.trim());
      }

      await firebaseUser.reload();
      await sendEmailVerification();
      await _session.clearStoredUser();
      return _session.mapFirebaseUser(
        _firebaseAuth.currentUser ?? firebaseUser,
      );
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> _rejectUnverifiedUser(User firebaseUser) async {
    await firebaseUser.sendEmailVerification();
    await _firebaseAuth.signOut();
    await _session.clearStoredUser();
    throw const AuthException(
      'Please verify your email before logging in. We sent you a '
      'fresh verification email.',
    );
  }
}
