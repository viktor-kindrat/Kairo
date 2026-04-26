import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';

abstract class IProfileRepository {
  Future<LocalUser?> getProfile();

  Future<ProfileUpdateResult> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  });

  Future<LocalUser> updateAvatar(String? avatarUrl);
}
