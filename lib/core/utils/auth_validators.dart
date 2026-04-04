import 'package:kairo/core/utils/email_validation.dart';

String normalizeEmail(String email) => email.trim().toLowerCase();

String? validateFullName(String value) {
  final normalizedValue = value.trim();

  if (normalizedValue.isEmpty) {
    return 'Please enter your full name.';
  }

  if (normalizedValue.length < 2) {
    return 'Full name must contain at least 2 characters.';
  }

  if (RegExp(r'\d').hasMatch(normalizedValue)) {
    return 'Full name cannot contain numbers.';
  }

  return null;
}

String? validateEmail(String value) {
  final normalizedValue = normalizeEmail(value);

  if (normalizedValue.isEmpty || !isEmailValid(normalizedValue)) {
    return 'Please enter a valid email address.';
  }

  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return 'Please enter a password.';
  }

  if (value.length < 8) {
    return 'Password must contain at least 8 characters.';
  }

  return null;
}

String? validateOptionalPassword(String value) {
  if (value.isEmpty) {
    return null;
  }

  return validatePassword(value);
}

String? validateCurrentPassword({
  required String currentPassword,
  required String enteredPassword,
}) {
  if (enteredPassword.isEmpty) {
    return 'Please enter your current password.';
  }

  if (currentPassword != enteredPassword) {
    return 'Current password is incorrect.';
  }

  return null;
}

String? validatePasswordConfirmation({
  required String password,
  required String confirmPassword,
}) {
  if (confirmPassword.isEmpty) {
    return 'Please confirm your password.';
  }

  if (password != confirmPassword) {
    return 'Passwords do not match.';
  }

  return null;
}

String maskPassword(String password) {
  if (password.isEmpty) {
    return 'Not set';
  }

  return List.filled(password.length.clamp(8, 12), '•').join();
}

String? validateRoleTitle(String value) {
  if (value.trim().isEmpty) {
    return 'Please enter a role title.';
  }

  return null;
}
