import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;

  AuthCubit({
    required IAuthRepository authRepository,
    required IProfileRepository profileRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(const AuthInitial());

  bool get needsReauthenticationForSensitiveAction =>
      _authRepository.needsReauthenticationForSensitiveAction;

  bool get requiresPasswordForReauthentication =>
      _authRepository.requiresPasswordForReauthentication;

  Future<void> refreshCurrentUser() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    await _syncCurrentUser(user);
  }

  void clearCurrentUser() => emit(const AuthUnauthenticated());

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final user =
        await _authRepository.signIn(email: email, password: password);
    return _syncCurrentUser(user);
  }

  Future<LocalUser?> signInWithGoogle() async {
    emit(const AuthLoading());
    final user = await _authRepository.signInWithGoogle();
    if (user == null) {
      emit(const AuthUnauthenticated());
      return null;
    }
    return _syncCurrentUser(user);
  }

  Future<LocalUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final user = await _authRepository.signUp(
      LocalUser(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleTitle: defaultRoleTitle,
      ),
    );
    emit(const AuthUnauthenticated());
    return user;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<bool> checkEmailVerified() async {
    final isVerified = await _authRepository.checkEmailVerified();
    if (!isVerified) return false;
    final user = await _authRepository.getCurrentUser();
    if (user == null) return false;
    await _syncCurrentUser(user);
    return true;
  }

  Future<void> resendVerificationCode() =>
      _authRepository.sendEmailVerification();

  Future<void> resetPassword(String email) =>
      _authRepository.sendPasswordResetEmail(email);

  Future<void> reauthenticateForSensitiveAction({String? password}) =>
      _authRepository.reauthenticate(password: password);

  Future<ProfileUpdateResult> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    final result = await _profileRepository.updateProfile(
      fullName: fullName,
      email: email,
      roleTitle: roleTitle,
      password: password,
    );
    if (result.requiresEmailReconfirmation) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(result.user));
    }
    return result;
  }

  Future<LocalUser> updateAvatar(String? avatarUrl) async {
    final updatedUser = await _profileRepository.updateAvatar(avatarUrl);
    emit(AuthAuthenticated(updatedUser));
    return updatedUser;
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    emit(const AuthUnauthenticated());
  }

  Future<LocalUser> _syncCurrentUser(LocalUser user) async {
    final profile = await _profileRepository.getProfile();
    final syncedUser = profile ?? user;
    emit(AuthAuthenticated(syncedUser));
    return syncedUser;
  }
}
