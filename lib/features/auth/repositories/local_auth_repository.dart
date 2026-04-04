import 'dart:math';

import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/features/auth/models/pending_email_verification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements IAuthRepository {
  final SharedPreferences _preferences;
  final Random _random;
  final LocalUserStore _userStore;

  LocalAuthRepository(
    this._preferences, {
    LocalUserStore? userStore,
    Random? random,
  }) : _random = random ?? Random(),
       _userStore = userStore ?? LocalUserStore(_preferences);

  @override
  Future<void> cancelPendingVerification() async {
    await _preferences.remove(pendingVerificationKey);
  }

  @override
  Future<void> deleteAccount() async {
    await _userStore.clearSessionEmail();
    await _userStore.clearUser();
    await _preferences.remove(pendingVerificationKey);
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
  Future<PendingEmailVerification?> getPendingVerification() async {
    final serializedPendingVerification = _preferences.getString(
      pendingVerificationKey,
    );

    if (serializedPendingVerification == null) {
      return null;
    }

    return PendingEmailVerification.fromJson(serializedPendingVerification);
  }

  @override
  Future<PendingEmailVerification> resendVerificationCode() async {
    final pendingVerification = await getPendingVerification();

    if (pendingVerification == null) {
      throw const AuthException('No pending email verification found.');
    }

    final updatedVerification = pendingVerification.copyWith(
      code: _generateVerificationCode(),
    );

    await _persistPendingVerification(updatedVerification);

    return updatedVerification;
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    final storedUser = _userStore.readUser();

    if (storedUser == null) {
      return false;
    }

    return normalizeEmail(storedUser.email) == normalizeEmail(email);
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
  Future<void> signOut() async {
    await _userStore.clearSessionEmail();
  }

  @override
  Future<PendingEmailVerification> signUp(LocalUser user) async {
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

    final pendingVerification = PendingEmailVerification(
      user: normalizedUser,
      code: _generateVerificationCode(),
    );

    await _persistPendingVerification(pendingVerification);
    await _userStore.clearSessionEmail();

    return pendingVerification;
  }

  @override
  Future<PendingEmailVerification> updatePendingVerificationEmail(
    String email,
  ) async {
    final pendingVerification = await getPendingVerification();
    final existingUser = _userStore.readUser();
    final normalizedEmail = normalizeEmail(email);

    if (pendingVerification == null) {
      throw const AuthException('No pending email verification found.');
    }

    if (existingUser != null &&
        normalizeEmail(existingUser.email) == normalizedEmail) {
      throw const AuthException('An account with this email already exists.');
    }

    final updatedVerification = pendingVerification.copyWith(
      user: pendingVerification.user.copyWith(email: normalizedEmail),
      code: _generateVerificationCode(),
    );

    await _persistPendingVerification(updatedVerification);

    return updatedVerification;
  }

  @override
  Future<LocalUser> verifyEmailCode(String code) async {
    final pendingVerification = await getPendingVerification();

    if (pendingVerification == null) {
      throw const AuthException('No pending email verification found.');
    }

    if (pendingVerification.code != code.trim()) {
      throw const AuthException('Invalid verification code. Try again.');
    }

    await _userStore.writeUserAndSession(pendingVerification.user);
    await _preferences.remove(pendingVerificationKey);

    return pendingVerification.user;
  }

  String _generateVerificationCode() {
    final verificationCode = _random.nextInt(1000000);
    return verificationCode.toString().padLeft(6, '0');
  }

  Future<void> _persistPendingVerification(
    PendingEmailVerification pendingVerification,
  ) async {
    await _preferences.setString(
      pendingVerificationKey,
      pendingVerification.toJson(),
    );
  }
}
