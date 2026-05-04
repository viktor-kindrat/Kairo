import 'package:kairo/core/utils/auth_validators.dart';

class ProfileAccountFieldErrors {
  final String? email;
  final String? fullName;
  final String? roleTitle;

  const ProfileAccountFieldErrors({
    required this.email,
    required this.fullName,
    required this.roleTitle,
  });

  bool get hasErrors => email != null || fullName != null || roleTitle != null;
}

ProfileAccountFieldErrors validateProfileAccountFields({
  required String email,
  required String fullName,
  required String roleTitle,
}) {
  return ProfileAccountFieldErrors(
    email: validateEmail(email),
    fullName: validateFullName(fullName),
    roleTitle: validateRoleTitle(roleTitle),
  );
}
