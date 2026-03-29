import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/auth/repositories/local_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAuthRepository', () {
    late SharedPreferences preferences;
    late LocalAuthRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      repository = LocalAuthRepository(preferences, random: Random(7));
    });

    test(
      'signUp creates pending verification but not active session',
      () async {
        const user = LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        );

        final pendingVerification = await repository.signUp(user);
        final currentUser = await repository.getCurrentUser();

        expect(pendingVerification.user.email, 'viktor@example.com');
        expect(pendingVerification.code, hasLength(6));
        expect(currentUser, isNull);
        expect(await repository.getPendingVerification(), isNotNull);
      },
    );

    test('duplicate signUp throws auth exception', () async {
      const user = LocalUser(
        fullName: 'Viktor Kindrat',
        email: 'viktor@example.com',
        password: 'password123',
        roleTitle: 'SOFTWARE ENGINEER',
      );

      final pendingVerification = await repository.signUp(user);
      await repository.verifyEmailCode(pendingVerification.code);
      await repository.signOut();

      expect(() => repository.signUp(user), throwsA(isA<AuthException>()));
    });

    test('verifyEmailCode stores user and creates session', () async {
      final pendingVerification = await repository.signUp(
        const LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        ),
      );

      final verifiedUser = await repository.verifyEmailCode(
        pendingVerification.code,
      );

      expect(verifiedUser.email, 'viktor@example.com');
      expect((await repository.getCurrentUser())?.email, 'viktor@example.com');
      expect(await repository.getPendingVerification(), isNull);
    });

    test('signIn throws on wrong password', () async {
      final pendingVerification = await repository.signUp(
        const LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        ),
      );
      await repository.verifyEmailCode(pendingVerification.code);
      await repository.signOut();

      expect(
        () => repository.signIn(
          email: 'viktor@example.com',
          password: 'bad-pass',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('signOut clears session but keeps stored account', () async {
      final pendingVerification = await repository.signUp(
        const LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        ),
      );
      await repository.verifyEmailCode(pendingVerification.code);

      await repository.signOut();

      final currentUser = await repository.getCurrentUser();
      final resetAvailable = await repository.sendPasswordResetEmail(
        'viktor@example.com',
      );

      expect(currentUser, isNull);
      expect(resetAvailable, isTrue);
    });

    test('change email updates pending verification email', () async {
      await repository.signUp(
        const LocalUser(
          fullName: 'Viktor Kindrat',
          email: 'viktor@example.com',
          password: 'password123',
          roleTitle: 'SOFTWARE ENGINEER',
        ),
      );

      final updatedVerification = await repository
          .updatePendingVerificationEmail('new@example.com');

      expect(updatedVerification.user.email, 'new@example.com');
      expect(
        (await repository.getPendingVerification())?.user.email,
        'new@example.com',
      );
    });

    test(
      'deleteAccount removes stored user, session, and pending data',
      () async {
        final pendingVerification = await repository.signUp(
          const LocalUser(
            fullName: 'Viktor Kindrat',
            email: 'viktor@example.com',
            password: 'password123',
            roleTitle: 'SOFTWARE ENGINEER',
          ),
        );
        await repository.verifyEmailCode(pendingVerification.code);

        await repository.deleteAccount();

        expect(await repository.getCurrentUser(), isNull);
        expect(await repository.getPendingVerification(), isNull);
        expect(
          await repository.sendPasswordResetEmail('viktor@example.com'),
          isFalse,
        );
      },
    );
  });
}
