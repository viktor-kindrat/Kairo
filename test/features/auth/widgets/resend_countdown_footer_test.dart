import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/features/auth/widgets/resend_countdown_footer.dart';

void main() {
  testWidgets('shows countdown text while resend is locked', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResendCountdownFooter(secondsRemaining: 18, onTap: _noop),
        ),
      ),
    );

    expect(find.text("Didn't receive it? Resend in 18s"), findsOneWidget);
    expect(find.text('Resend'), findsNothing);
  });

  testWidgets('shows resend action when countdown completes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResendCountdownFooter(secondsRemaining: 0, onTap: () {}),
        ),
      ),
    );

    expect(find.text("Didn't receive it? "), findsOneWidget);
    expect(find.text('Resend'), findsOneWidget);
  });
}

void _noop() {}
