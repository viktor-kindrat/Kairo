import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';

AuthException mapFirebaseAuthException(FirebaseAuthException error) {
  switch (error.code) {
    case 'user-not-found':
      return const AuthException(
        'We could not find an account with this email.',
      );
    case 'wrong-password':
      return const AuthException('Incorrect password. Please try again.');
    case 'invalid-credential':
      return const AuthException(
        'The email or password is incorrect. Please try again.',
      );
    case 'invalid-email':
      return const AuthException('Please enter a valid email address.');
    case 'email-already-in-use':
      return const AuthException('An account with this email already exists.');
    case 'weak-password':
      return const AuthException(
        'Password must contain at least 8 characters.',
      );
    case 'too-many-requests':
      return const AuthException(
        'Too many attempts. Please wait a moment and try again.',
      );
    case 'network-request-failed':
      return const AuthException(
        'No internet connection. Please try again when you are back online.',
      );
    default:
      return AuthException(
        error.message ?? 'Authentication failed. Please try again.',
      );
  }
}
