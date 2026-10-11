import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/features/auth/utils/firebase_auth_error_mapper.dart';

class FirebaseAuthSession {
  final Connectivity connectivity;
  final FirebaseAuth firebaseAuth;
  final LocalUserStore userStore;

  const FirebaseAuthSession({
    required this.connectivity,
    required this.firebaseAuth,
    required this.userStore,
  });

  bool get needsReauthenticationForSensitiveAction {
    final lastSignInTime = firebaseAuth.currentUser?.metadata.lastSignInTime;

    if (lastSignInTime == null) {
      return true;
    }

    return DateTime.now().difference(lastSignInTime) >
        const Duration(minutes: 1);
  }

  bool get requiresPasswordForReauthentication {
    final providerIds = firebaseAuth.currentUser?.providerData.map(
      (provider) => provider.providerId,
    );

    return !(providerIds?.contains(GoogleAuthProvider.PROVIDER_ID) ?? false);
  }

  Future<bool> checkEmailVerified() async {
    await ensureConnection();

    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        return false;
      }

      await currentUser.reload();
      final refreshedUser = firebaseAuth.currentUser;
      final isVerified = refreshedUser?.emailVerified ?? false;

      if (isVerified && refreshedUser != null) {
        await persistAuthenticatedUser(refreshedUser);
      }

      return isVerified;
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> clearStoredUser() async {
    await userStore.clearSessionEmail();
    await userStore.clearUser();
  }

  Future<void> deleteAccount() async {
    await ensureConnection();

    try {
      await firebaseAuth.currentUser?.delete();
      await clearStoredUser();
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  Future<void> ensureConnection() async {
    final results = await connectivity.checkConnectivity();
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnection) {
      throw const AuthException(
        'No internet connection. Please try again when you are back online.',
      );
    }
  }

  Future<LocalUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null || !firebaseUser.emailVerified) {
      await clearStoredUser();
      return null;
    }

    return persistAuthenticatedUser(firebaseUser);
  }

  Future<void> reauthenticateWithPassword(String? password) async {
    await ensureConnection();

    final currentUser = firebaseAuth.currentUser;
    final email = currentUser?.email;

    if (currentUser == null || email == null) {
      throw const AuthException('Please sign in again to continue.');
    }

    if (password == null || password.isEmpty) {
      throw const AuthException('Please enter your password.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.getIdToken(true);
    } on FirebaseAuthException catch (error) {
      throw mapFirebaseAuthException(error);
    }
  }

  LocalUser mapFirebaseUser(User user) {
    return LocalUser(
      fullName: user.displayName?.trim() ?? '',
      email: user.email ?? '',
      password: '',
      roleTitle: defaultRoleTitle,
    );
  }

  Future<LocalUser> persistAuthenticatedUser(User user) async {
    final localUser = mapFirebaseUser(user);
    await userStore.writeUserAndSession(localUser);
    return localUser;
  }
}
