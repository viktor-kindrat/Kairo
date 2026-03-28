import 'dart:async';

class AuthService {
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Replace with real API call to send password reset email

      await Future<void>.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      return false;
    }
  }
}
