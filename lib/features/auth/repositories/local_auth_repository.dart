import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements IAuthRepository {
  final LocalUserStore _userStore;

  LocalAuthRepository(
    SharedPreferences preferences, {
    LocalUserStore? userStore,
  }) : _userStore = userStore ?? LocalUserStore(preferences);

  @override
  Future<void> deleteAccount() async {
    await _userStore.clearSessionEmail();
    await _userStore.clearUser();
  }

  @override
  Future<LocalUser?> getCurrentUser() async {
    final sessionEmail = _userStore.readSessionEmail();
    final storedUser = _userStore.readUser();

    if (sessionEmail == null || storedUser == null) {
      return null;
    }

    if (normalizeEmail(storedUser.email) != normalizeEmail(sessionEmail)) {
      return null;
    }

    return storedUser;
  }

  @override
  Future<bool> checkEmailVerified() async {
    final currentUser = _userStore.readUser();
    final sessionEmail = _userStore.readSessionEmail();

    if (currentUser == null || sessionEmail == null) {
      return false;
    }

    return normalizeEmail(currentUser.email) == normalizeEmail(sessionEmail);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final storedUser = _userStore.readUser();

    if (storedUser == null) {
      throw const AuthException('No account found with this email.');
    }

    if (normalizeEmail(storedUser.email) != normalizeEmail(email)) {
      throw const AuthException('No account found with this email.');
    }
  }

  @override
  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final storedUser = _userStore.readUser();

    if (storedUser == null) {
      throw const AuthException(
        'No account found yet. Please sign up before logging in.',
      );
    }

    if (normalizeEmail(storedUser.email) != normalizeEmail(email)) {
      throw const AuthException(
        'We could not find an account with this email.',
      );
    }

    if (storedUser.password != password) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    await _userStore.writeSessionEmail(storedUser.email);

    return storedUser;
  }

  @override
  Future<LocalUser?> signInWithGoogle() async {
    throw const AuthException(
      'Google sign-in is not available in local auth mode.',
    );
  }

  @override
  Future<void> signOut() async {
    await _userStore.clearSessionEmail();
  }

  @override
  Future<LocalUser> signUp(LocalUser user) async {
    final existingUser = _userStore.readUser();
    final normalizedUser = user.copyWith(
      fullName: user.fullName.trim(),
      email: normalizeEmail(user.email),
      roleTitle: user.roleTitle.trim(),
    );

    if (existingUser != null &&
        normalizeEmail(existingUser.email) ==
            normalizeEmail(normalizedUser.email)) {
      throw const AuthException('An account with this email already exists.');
    }
    await _userStore.clearSessionEmail();

    return normalizedUser;
  }
}
