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
}
