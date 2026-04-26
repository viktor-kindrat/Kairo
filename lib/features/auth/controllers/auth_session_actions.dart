import 'package:flutter/foundation.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';

mixin AuthSessionActions on ChangeNotifier {
  IAuthRepository get authRepository;
  IProfileRepository get profileRepository;
  void setCurrentUser(LocalUser? user, {bool notify});

  Future<void> deleteAccount() => _clearAfter(authRepository.deleteAccount());

  Future<void> resetPassword(String email) {
    return authRepository.sendPasswordResetEmail(email);
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await authRepository.signIn(email: email, password: password);
    return _syncCurrentUser(user);
  }

  Future<LocalUser?> signInWithGoogle() async {
    final user = await authRepository.signInWithGoogle();

    if (user == null) {
      return null;
    }

    return _syncCurrentUser(user);
  }

  Future<void> signOut() => _clearAfter(authRepository.signOut());

  Future<LocalUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await authRepository.signUp(
      LocalUser(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleTitle: defaultRoleTitle,
      ),
    );
    setCurrentUser(null, notify: false);
    return user;
  }

  Future<void> resendVerificationCode() {
    return authRepository.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final isVerified = await authRepository.checkEmailVerified();

    if (!isVerified) {
      return false;
    }

    final user = await authRepository.getCurrentUser();

    if (user == null) {
      throw const AuthException(
        'Your email is verified, but we could not restore your account. '
        'Please log in again.',
      );
    }

    await _syncCurrentUser(user);
    return true;
  }

  Future<void> refreshCurrentUser() async {
    final user = await authRepository.getCurrentUser();

    if (user == null) {
      setCurrentUser(null);
      return;
    }

    await _syncCurrentUser(user);
  }

  void clearCurrentUser({bool notify = true}) {
    setCurrentUser(null, notify: notify);
  }

  Future<void> _clearAfter(Future<void> action) async {
    await action;
    clearCurrentUser();
  }

  Future<LocalUser> _syncCurrentUser(LocalUser user) async {
    final profile = await profileRepository.getProfile();
    final syncedUser = profile ?? user;
    setCurrentUser(syncedUser);
    return syncedUser;
  }
}
