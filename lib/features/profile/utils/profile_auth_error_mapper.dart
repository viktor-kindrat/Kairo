import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';

AuthException mapProfileAuthException(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return const AuthException('Please enter a valid email address.');
    case 'email-already-in-use':
    case 'credential-already-in-use':
      return const AuthException('An account with this email already exists.');
    case 'requires-recent-login':
      return const AuthException(
        'For security reasons, please sign in again before changing '
        'your email.',
      );
    case 'network-request-failed':
      return const AuthException(
        'No internet connection. Please try again when you are back online.',
      );
    default:
      return AuthException(
        error.message ?? 'We could not update your account right now.',
      );
  }
}
