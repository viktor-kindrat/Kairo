import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';

void main() {
  testWidgets('renders handle, title, description and default padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(
          home: Scaffold(
            body: AppFormSheetLayout(
              title: 'Sheet Title',
              description: 'Helpful description',
              children: [Text('Child content')],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('app_form_sheet_handle')), findsOneWidget);
    expect(find.text('Sheet Title'), findsOneWidget);
    expect(find.text('Helpful description'), findsOneWidget);
    expect(find.text('Child content'), findsOneWidget);

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );

    expect(scrollView.padding, const EdgeInsets.fromLTRB(24, 18, 24, 24));
  });
}
