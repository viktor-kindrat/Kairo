import 'package:flutter/foundation.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;

  LocalUser? _currentUser;

  AuthController({
    required IAuthRepository authRepository,
    required IProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  LocalUser? get currentUser => _currentUser;

  Future<void> initialize() async {
    await refreshCurrentUser();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    clearCurrentUser();
  }

  Future<void> resetPassword(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signIn(email: email, password: password);
    _currentUser = user;
    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    clearCurrentUser();
  }

  Future<LocalUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signUp(
      LocalUser(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleTitle: defaultRoleTitle,
      ),
    );
    clearCurrentUser(notify: false);
    return user;
  }

  Future<void> resendVerificationCode() async {
    await _authRepository.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final isVerified = await _authRepository.checkEmailVerified();

    if (!isVerified) {
      return false;
    }

    final user = await _authRepository.getCurrentUser();

    if (user == null) {
      throw const AuthException(
        'Your email is verified, but we could not restore your account. '
        'Please log in again.',
      );
    }

    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<void> refreshCurrentUser() async {
    final user = await _authRepository.getCurrentUser();

    if (_currentUser == user) {
      return;
    }

    _currentUser = user;
    notifyListeners();
  }

  void clearCurrentUser({bool notify = true}) {
    if (_currentUser == null) {
      return;
    }

    _currentUser = null;

    if (notify) {
      notifyListeners();
    }
  }

  Future<LocalUser> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('Please log in to update your profile.');
    }

    final updatedUser = await _profileRepository.updateProfile(
      fullName: fullName,
      email: email,
      roleTitle: roleTitle,
      password: password,
    );

    _currentUser = updatedUser;
    notifyListeners();
    return updatedUser;
  }

  Future<LocalUser> updateAvatar(String? avatarPath) async {
    if (_currentUser == null) {
      throw const AuthException('Please log in to update your profile.');
    }

    final updatedUser = await _profileRepository.updateAvatar(avatarPath);

    _currentUser = updatedUser;
    notifyListeners();
    return updatedUser;
  }
}
