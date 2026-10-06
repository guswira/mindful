import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/journal/domain/journal_entry.dart';
import 'package:mindful/features/journal/presentation/journal_labels.dart';
import 'package:mindful/features/journal/presentation/add_journal_sheet.dart';
import 'package:mindful/shared/widgets/shake_widget.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

void main() {
  Widget buildSheet({JournalType initialType = JournalType.review}) =>
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: AddJournalSheet(initialType: initialType)),
        ),
      );

  testWidgets('shows the body field, mood picker and save pill', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text("What's going on"), findsOneWidget);
    expect(find.text('How did today go?'), findsOneWidget);
    for (final mood in Mood.values) {
      expect(find.byIcon(moodIcon(mood)), findsOneWidget);
    }
    expect(find.widgetWithText(TintedPill, 'Save entry'), findsOneWidget);
  });

  testWidgets('autofocuses the body field on open', (tester) async {
    await tester.pumpWidget(buildSheet());
    await tester.pump();

    final bodyField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'How did today go?', skipOffstage: false),
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

    await tester.tap(find.byIcon(moodIcon(Mood.happy)));
    await tester.pumpAndSettle();

    final scale = tester.widget<AnimatedScale>(
      find.ancestor(
        of: find.byIcon(moodIcon(Mood.happy)),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(scale.scale, 1.3);
  });

  testWidgets('offers the three journal types, Today review by default', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('Today review'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Gratitude'), findsOneWidget);
    // The body hint follows the selected type.
    expect(find.text('How did today go?'), findsOneWidget);
  });

  testWidgets('starts on initialType and switches the hint with the type', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(initialType: JournalType.plan));

    expect(find.text('What do you want to get done today?'), findsOneWidget);

    await tester.tap(find.text('Gratitude'));
    await tester.pump();

    expect(find.text('What are you grateful for today?'), findsOneWidget);
  });
}
