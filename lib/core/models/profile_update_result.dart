import 'package:kairo/core/models/local_user.dart';

class ProfileUpdateResult {
  final LocalUser user;
  final bool requiresEmailReconfirmation;

  const ProfileUpdateResult({
    required this.user,
    this.requiresEmailReconfirmation = false,
  });
}
