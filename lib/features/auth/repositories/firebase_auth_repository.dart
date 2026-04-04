import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final Connectivity _connectivity;
  final LocalUserStore _userStore;

  FirebaseAuthRepository({
    required LocalUserStore userStore,
    FirebaseAuth? firebaseAuth,
    Connectivity? connectivity,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity(),
       _userStore = userStore;

  @override
  Future<bool> checkEmailVerified() async {
    await _ensureConnection();

    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        return false;
      }

      await currentUser.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      final isVerified = refreshedUser?.emailVerified ?? false;

      if (isVerified && refreshedUser != null) {
        await _persistAuthenticatedUser(refreshedUser);
      }

      return isVerified;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _ensureConnection();

    try {
      final currentUser = _firebaseAuth.currentUser;
      await currentUser?.delete();
      await _userStore.clearSessionEmail();
      await _userStore.clearUser();
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<LocalUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      await _userStore.clearSessionEmail();
      await _userStore.clearUser();
      return null;
    }

    if (!firebaseUser.emailVerified) {
      await _userStore.clearSessionEmail();
      await _userStore.clearUser();
      return null;
    }

    final localUser = _mapFirebaseUser(firebaseUser);
    await _userStore.writeUserAndSession(localUser);
    return localUser;
  }

  @override
  Future<void> sendEmailVerification() async {
    await _ensureConnection();

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
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _ensureConnection();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: normalizeEmail(email));
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureConnection();

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
        await firebaseUser.sendEmailVerification();
        await _firebaseAuth.signOut();
        await _userStore.clearSessionEmail();
        await _userStore.clearUser();
        throw const AuthException(
          'Please verify your email before logging in. We sent you a '
          'fresh verification email.',
        );
      }

      return _persistAuthenticatedUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureConnection();

    try {
      await _firebaseAuth.signOut();
      await _userStore.clearSessionEmail();
      await _userStore.clearUser();
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<LocalUser> signUp(LocalUser user) async {
    await _ensureConnection();

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
      await _userStore.clearSessionEmail();
      await _userStore.clearUser();

      return _mapFirebaseUser(_firebaseAuth.currentUser ?? firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<void> _ensureConnection() async {
    final results = await _connectivity.checkConnectivity();
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const AuthException(
        'No internet connection. Please try again when you are back online.',
      );
    }
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return const AuthException(
          'We could not find an account with this email.',
        );
      case 'wrong-password':
        return const AuthException('Incorrect password. Please try again.');
      case 'invalid-credential':
        return const AuthException(
          'The email or password is incorrect. Please try again.',
        );
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.');
      case 'email-already-in-use':
        return const AuthException(
          'An account with this email already exists.',
        );
      case 'weak-password':
        return const AuthException(
          'Password must contain at least 8 characters.',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please wait a moment and try again.',
        );
      case 'network-request-failed':
        return const AuthException(
          'No internet connection. Please try again when you are back online.',
        );
      default:
        return AuthException(
          error.message ?? 'Authentication failed. Please try again.',
        );
    }
  }

  LocalUser _mapFirebaseUser(User user) {
    return LocalUser(
      fullName: user.displayName?.trim() ?? '',
      email: user.email ?? '',
      password: '',
      roleTitle: defaultRoleTitle,
    );
  }

  Future<LocalUser> _persistAuthenticatedUser(User user) async {
    final localUser = _mapFirebaseUser(user);
    await _userStore.writeUserAndSession(localUser);
    return localUser;
  }
}
