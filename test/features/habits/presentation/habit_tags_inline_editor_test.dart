import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/domain/habit_tag.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet_actions.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('adds, renames and removes tags in place', (tester) async {
    var tags = const [HabitTag(id: 't1', label: 'Heavy')];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => HabitTagsInlineEditor(
              tags: tags,
              onChanged: (next) => setState(() => tags = next),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Heavy'), findsOneWidget);

    await tester.tap(find.text('+ Add tag'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Easy');
    await tester.pump();
    expect(tags.map((tag) => tag.label), ['Heavy', 'Easy']);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(tags.map((tag) => tag.label), ['Easy']);
  });
}
