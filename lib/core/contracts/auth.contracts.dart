import 'package:kairo/core/models/local_user.dart';

abstract class IAuthRepository {
  Future<LocalUser> signIn({required String email, required String password});

  Future<LocalUser> signUp(LocalUser user);

  Future<void> sendEmailVerification();

  Future<bool> checkEmailVerified();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<LocalUser?> getCurrentUser();

  Future<void> deleteAccount();
}
