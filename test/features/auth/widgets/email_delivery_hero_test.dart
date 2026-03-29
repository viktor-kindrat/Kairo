import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/features/auth/widgets/email_delivery_hero.dart';

void main() {
  testWidgets('renders illustration, copy and email pill', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmailDeliveryHero(
            email: 'demo@example.com',
            headline: 'Check your inbox.',
            subHeadline: 'We sent a link to',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Check your inbox.'), findsOneWidget);
    expect(find.text('We sent a link to'), findsOneWidget);
    expect(find.text('demo@example.com'), findsOneWidget);
  });
}
