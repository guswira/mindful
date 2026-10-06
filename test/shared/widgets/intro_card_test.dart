import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/intro_card.dart';

void main() {
  testWidgets('shows its intro and runs onAction from the pill', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: Scaffold(
          body: IntroCard(
            icon: Icons.eco_outlined,
            color: Colors.purple,
            title: 'Routines repeat every day',
            body: 'Pick a small habit.',
            actionLabel: 'Add routine',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Routines repeat every day'), findsOneWidget);
    expect(find.text('Pick a small habit.'), findsOneWidget);
    expect(find.byIcon(Icons.eco_outlined), findsOneWidget);

    await tester.tap(find.text('Add routine'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
