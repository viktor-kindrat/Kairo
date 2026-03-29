import 'package:flutter/foundation.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/auth/models/pending_email_verification.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;

  LocalUser? _currentUser;
  PendingEmailVerification? _pendingVerification;

  AuthController({
    required IAuthRepository authRepository,
    required IProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository;

  LocalUser? get currentUser => _currentUser;

  PendingEmailVerification? get pendingVerification => _pendingVerification;

  bool get isAuthenticated => _currentUser != null;

  bool get hasPendingVerification => _pendingVerification != null;

  Future<void> initialize() async {
    _currentUser = await _authRepository.getCurrentUser();
    _pendingVerification = _currentUser == null
        ? await _authRepository.getPendingVerification()
        : null;
  }

  Future<void> cancelPendingVerification() async {
    await _authRepository.cancelPendingVerification();
    _pendingVerification = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    _currentUser = null;
    _pendingVerification = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    final success = await _authRepository.sendPasswordResetEmail(email);

    if (!success) {
      throw const AuthException('No account found with this email.');
    }
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
    _currentUser = null;
    notifyListeners();
  }

  Future<PendingEmailVerification> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final pendingVerification = await _authRepository.signUp(
      LocalUser(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleTitle: defaultRoleTitle,
      ),
    );

    _currentUser = null;
    _pendingVerification = pendingVerification;
    notifyListeners();
    return pendingVerification;
  }

  Future<PendingEmailVerification> resendVerificationCode() async {
    final pendingVerification = await _authRepository.resendVerificationCode();
    _pendingVerification = pendingVerification;
    notifyListeners();
    return pendingVerification;
  }

  Future<PendingEmailVerification> updatePendingVerificationEmail(
    String email,
  ) async {
    final pendingVerification = await _authRepository
        .updatePendingVerificationEmail(email);
    _pendingVerification = pendingVerification;
    notifyListeners();
    return pendingVerification;
  }

  Future<LocalUser> verifyEmailCode(String code) async {
    final user = await _authRepository.verifyEmailCode(code);
    _currentUser = user;
    _pendingVerification = null;
    notifyListeners();
    return user;
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
