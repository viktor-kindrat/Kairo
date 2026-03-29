import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/utils/auth_validators.dart';

void main() {
  group('auth validators', () {
    test('validates full name without numbers', () {
      expect(validateFullName('Viktor'), isNull);
      expect(validateFullName('V1ktor'), 'Full name cannot contain numbers.');
    });

    test('validates email format', () {
      expect(validateEmail('demo@example.com'), isNull);
      expect(
        validateEmail('not-an-email'),
        'Please enter a valid email address.',
      );
    });

    test('validates password length', () {
      expect(validatePassword('12345678'), isNull);
      expect(
        validatePassword('1234'),
        'Password must contain at least 8 characters.',
      );
    });

    test('validates password confirmation', () {
      expect(
        validatePasswordConfirmation(
          password: 'password123',
          confirmPassword: 'password123',
        ),
        isNull,
      );
      expect(
        validatePasswordConfirmation(
          password: 'password123',
          confirmPassword: 'password124',
        ),
        'Passwords do not match.',
      );
    });

    test('validates optional password and masks password', () {
      expect(validateOptionalPassword(''), isNull);
      expect(
        validateOptionalPassword('short'),
        'Password must contain at least 8 characters.',
      );
      expect(maskPassword('password123'), '•••••••••••');
    });
  });
}
