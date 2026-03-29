import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/profile/repositories/local_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalProfileRepository', () {
    late SharedPreferences preferences;
    late LocalProfileRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        storedUserKey: const LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        ).toJson(),
        authSessionKey: 'viktor@example.com',
      });
      preferences = await SharedPreferences.getInstance();
      repository = LocalProfileRepository(preferences);
    });

    test('updates stored profile fields', () async {
      final updatedUser = await repository.updateProfile(
        fullName: 'Viktor K.',
        email: 'new-email@example.com',
        roleTitle: 'MOBILE ENGINEER',
        password: 'updatedPassword123',
      );

      final storedProfile = await repository.getProfile();

      expect(updatedUser.fullName, 'Viktor K.');
      expect(updatedUser.email, 'new-email@example.com');
      expect(updatedUser.password, 'updatedPassword123');
      expect(updatedUser.roleTitle, 'MOBILE ENGINEER');
      expect(storedProfile?.fullName, 'Viktor K.');
      expect(preferences.getString(authSessionKey), 'new-email@example.com');
    });

    test('updates avatar path', () async {
      final updatedUser = await repository.updateAvatar('/tmp/avatar.png');
      final storedProfile = await repository.getProfile();

      expect(updatedUser.avatarPath, '/tmp/avatar.png');
      expect(storedProfile?.avatarPath, '/tmp/avatar.png');
    });
  });
}
