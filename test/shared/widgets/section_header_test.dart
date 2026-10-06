import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/shared/widgets/section_header.dart';

void main() {
  testWidgets('shows the title and runs onAction when the action is tapped', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: Scaffold(
          body: SectionHeader(
            title: 'Breathing exercise',
            actionLabel: 'History',
            onAction: () => tapped++,
          ),
        ),
      ),
    );

    expect(find.text('Breathing exercise'), findsOneWidget);
    await tester.tap(find.text('History'));
    expect(tapped, 1);
  });
}
