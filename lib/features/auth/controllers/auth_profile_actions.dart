import 'package:flutter/foundation.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';

mixin AuthProfileActions on ChangeNotifier {
  LocalUser? get currentUser;
  IProfileRepository get profileRepository;
  void clearCurrentUser({bool notify});
  void setCurrentUser(LocalUser? user, {bool notify});

  Future<ProfileUpdateResult> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    if (currentUser == null) {
      throw const AuthException('Please log in to update your profile.');
    }

    final updateResult = await profileRepository.updateProfile(
      fullName: fullName,
      email: email,
      roleTitle: roleTitle,
      password: password,
    );

    if (updateResult.requiresEmailReconfirmation) {
      clearCurrentUser();
    } else {
      setCurrentUser(updateResult.user);
    }

    return updateResult;
  }

  Future<LocalUser> updateAvatar(String? avatarUrl) async {
    if (currentUser == null) {
      throw const AuthException('Please log in to update your profile.');
    }

    final updatedUser = await profileRepository.updateAvatar(avatarUrl);
    setCurrentUser(updatedUser);
    return updatedUser;
  }
}
