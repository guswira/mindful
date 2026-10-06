import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/shared/widgets/tinted_pill.dart';

void main() {
  testWidgets('shows its label and calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TintedPill(
            label: 'Start',
            color: Colors.teal,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('full width centers the label, with an optional icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: TintedPill(
              label: 'Sign in',
              color: Colors.teal,
              icon: Icons.login,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.login), findsOneWidget);
    final pill = tester.getRect(find.byType(TintedPill));
    final content = tester.getRect(find.byType(Row));
    expect(pill.width, 300);
    expect(content.center.dx, closeTo(pill.center.dx, 0.5));
  });
}
