import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/app_theme.dart';
import 'package:mindfull/features/journal/domain/journal_entry.dart';
import 'package:mindfull/features/journal/presentation/add_journal_sheet.dart';
import 'package:mindfull/shared/widgets/shake_widget.dart';
import 'package:mindfull/shared/widgets/tinted_pill.dart';

void main() {
  Widget buildSheet() => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: AddJournalSheet()),
    ),
  );

  testWidgets('shows the body field, mood picker and save pill', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text("What's going on"), findsOneWidget);
    expect(find.text("What's on your mind..."), findsOneWidget);
    for (final mood in Mood.values) {
      expect(find.text(mood.emoji), findsOneWidget);
    }
    expect(find.widgetWithText(TintedPill, 'Save entry'), findsOneWidget);
  });

  testWidgets('autofocuses the body field on open', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pump();

    final bodyField = tester.widget<TextField>(
      find.widgetWithText(
        TextField,
        "What's on your mind...",
        skipOffstage: false,
      ),
    );
    expect(bodyField.autofocus, isTrue);
  });

  testWidgets(
    'tapping "Save entry" with an empty body is a no-op and shakes the field',
    (tester) async {
      await tester.pumpWidget(buildSheet());

      await tester.tap(find.widgetWithText(TintedPill, 'Save entry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ShakeWidget),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform.getTranslation().x, isNot(0));

      await tester.pumpAndSettle();
      expect(find.byType(AddJournalSheet), findsOneWidget);
    },
  );

  testWidgets('selecting a mood scales it up', (tester) async {
    await tester.pumpWidget(buildSheet());

    await tester.tap(find.text(Mood.happy.emoji));
    await tester.pumpAndSettle();

    final scale = tester.widget<AnimatedScale>(
      find.ancestor(
        of: find.text(Mood.happy.emoji),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(scale.scale, 1.3);
  });
}
