import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileRepository implements IProfileRepository {
  final FirebaseAuth _firebaseAuth;
  final LocalUserStore _userStore;

  LocalProfileRepository(
    SharedPreferences preferences, {
    FirebaseAuth? firebaseAuth,
    LocalUserStore? userStore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _userStore = userStore ?? LocalUserStore(preferences);

  @override
  Future<LocalUser?> getProfile() async {
    return _userStore.readUser();
  }

  @override
  Future<ProfileUpdateResult> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    final currentUser = await getProfile();
    final firebaseUser = _firebaseAuth.currentUser;

    if (currentUser == null || firebaseUser == null) {
      throw const AuthException('No profile found to update.');
    }

    final normalizedEmail = normalizeEmail(email);
    final updatedUser = currentUser.copyWith(
      fullName: fullName.trim(),
      email: normalizedEmail,
      password: password,
      roleTitle: roleTitle.trim(),
    );
    final emailChanged =
        normalizeEmail(currentUser.email) != normalizedEmail;

    try {
      if (updatedUser.fullName != (firebaseUser.displayName ?? '')) {
        await firebaseUser.updateDisplayName(updatedUser.fullName);
      }

      if (emailChanged) {
        await firebaseUser.verifyBeforeUpdateEmail(normalizedEmail);
        await _firebaseAuth.signOut();
        await _userStore.clearSessionEmail();
        await _userStore.clearUser();

        return ProfileUpdateResult(
          user: updatedUser,
          requiresEmailReconfirmation: true,
        );
      }

      await firebaseUser.reload();
      await _userStore.writeUserAndSession(updatedUser);

      return ProfileUpdateResult(user: updatedUser);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<LocalUser> updateAvatar(String? avatarPath) async {
    final currentUser = await getProfile();

    if (currentUser == null) {
      throw const AuthException('No profile found to update.');
    }

    final updatedUser = currentUser.copyWith(
      avatarPath: avatarPath,
      clearAvatarPath: avatarPath == null,
    );

    await _userStore.writeUser(updatedUser);

    return updatedUser;
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AuthException('Please enter a valid email address.');
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return const AuthException(
          'An account with this email already exists.',
        );
      case 'requires-recent-login':
        return const AuthException(
          'For security reasons, please sign in again before changing '
          'your email.',
        );
      case 'network-request-failed':
        return const AuthException(
          'No internet connection. Please try again when you are back online.',
        );
      default:
        return AuthException(
          error.message ?? 'We could not update your account right now.',
        );
    }
  }
}
