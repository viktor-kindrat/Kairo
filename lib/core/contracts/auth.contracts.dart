import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/auth/models/pending_email_verification.dart';

abstract class IAuthRepository {
  Future<LocalUser> signIn({required String email, required String password});

  Future<PendingEmailVerification> signUp(LocalUser user);

  Future<PendingEmailVerification?> getPendingVerification();

  Future<PendingEmailVerification> resendVerificationCode();

  Future<PendingEmailVerification> updatePendingVerificationEmail(String email);

  Future<LocalUser> verifyEmailCode(String code);

  Future<void> cancelPendingVerification();

  Future<void> signOut();

  Future<bool> sendPasswordResetEmail(String email);

  Future<LocalUser?> getCurrentUser();

  Future<void> deleteAccount();
}
