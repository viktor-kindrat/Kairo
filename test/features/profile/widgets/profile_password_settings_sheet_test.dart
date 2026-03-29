import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/profile/widgets/profile_password_settings_sheet.dart';

void main() {
  testWidgets('validates current, new and confirm password fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePasswordSettingsSheet(
            user: const LocalUser(
              fullName: 'Alex Smith',
              email: 'alex@example.com',
              password: 'password123',
              roleTitle: 'PRO MEMBER',
            ),
            onSave: (_) async {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong-password');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await tester.tap(find.text('Update Password'));
    await tester.pump();

    expect(find.text('Current password is incorrect.'), findsOneWidget);
    expect(
      find.text('Password must contain at least 8 characters.'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match.'), findsOneWidget);
  });
}
