import 'package:kairo/core/models/local_user.dart';

abstract class IProfileRepository {
  Future<LocalUser?> getProfile();

  Future<LocalUser> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  });

  Future<LocalUser> updateAvatar(String? avatarPath);
}
