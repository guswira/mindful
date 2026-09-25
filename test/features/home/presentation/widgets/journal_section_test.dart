import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/home/presentation/widgets/journal_section.dart';
import 'package:mindfull/features/journal/presentation/add_journal_sheet.dart';

Widget _buildSection() => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: [GlassTheme.dark()]),
    home: const Scaffold(body: JournalSection()),
  ),
);

void main() {
  testWidgets('shows both journal prompts', (tester) async {
    await tester.pumpWidget(_buildSection());

    expect(find.text("Write today's plan"), findsOneWidget);
    expect(find.text('Review what happened'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reflect'), findsOneWidget);
  });

  testWidgets('tapping "Start" opens the quick journal entry sheet', (
    tester,
  ) async {
    await tester.pumpWidget(_buildSection());

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byType(AddJournalSheet), findsOneWidget);
  });
}
