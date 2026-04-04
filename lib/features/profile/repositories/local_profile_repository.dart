import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileRepository implements IProfileRepository {
  final LocalUserStore _userStore;

  LocalProfileRepository(
    SharedPreferences preferences, {
    LocalUserStore? userStore,
  }) : _userStore = userStore ?? LocalUserStore(preferences);

  @override
  Future<LocalUser?> getProfile() async {
    return _userStore.readUser();
  }

  @override
  Future<LocalUser> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    final currentUser = await getProfile();

    if (currentUser == null) {
      throw const AuthException('No profile found to update.');
    }

    final updatedUser = currentUser.copyWith(
      fullName: fullName.trim(),
      email: normalizeEmail(email),
      password: password,
      roleTitle: roleTitle.trim(),
    );

    await _userStore.writeUserAndSession(updatedUser);

    return updatedUser;
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
}
