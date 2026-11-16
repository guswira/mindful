import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/money/presentation/widgets/recap_section.dart';
import 'package:mindful/l10n/generated/app_localizations.dart';
import 'package:mindful/shared/models/sync_status.dart';

class _MockBox extends Mock implements Box<dynamic> {}

MoneyEntry _entry(String id, DateTime date, double amount, String category) =>
    MoneyEntry(
      id: id,
      userId: 'u1',
      type: EntryType.spending,
      amount: amount,
      category: category,
      date: date,
      createdAt: date,
      updatedAt: date,
      syncStatus: SyncStatus.synced,
    );

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final lastMonth = DateTime(now.year, now.month - 1, 10);
  final twoMonthsAgo = DateTime(now.year, now.month - 2, 10);
  late _MockBox entriesBox;

  setUp(() {
    entriesBox = _MockBox();
  });

  Widget buildApp() => ProviderScope(
    overrides: [
      moneyRepositoryProvider.overrideWith(
        (ref) async =>
            MoneyRepository(entriesBox: entriesBox, settingsBox: _MockBox()),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SingleChildScrollView(child: RecapSection())),
    ),
  );

  Future<void> expand(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recap'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows this month, with no history link when none', (
    tester,
  ) async {
    when(
      () => entriesBox.values,
    ).thenReturn([_entry('a', today, 10, 'Food').toJson()]);

    await expand(tester);

    expect(find.text(DateFormat.yMMMM().format(now)), findsOneWidget);
    expect(find.text('Top category: Food'), findsOneWidget);
    expect(find.text('AI advice'), findsOneWidget);
    expect(find.text('Previous months'), findsNothing);
  });

  testWidgets('history pages through earlier months with entries', (
    tester,
  ) async {
    when(() => entriesBox.values).thenReturn([
      _entry('a', today, 10, 'Food').toJson(),
      _entry('b', lastMonth, 20, 'Travel').toJson(),
      _entry('c', twoMonthsAgo, 30, 'Health').toJson(),
    ]);

    await expand(tester);
    await tester.tap(find.text('Previous months'));
    await tester.pumpAndSettle();

    expect(find.text('Cashflow history'), findsOneWidget);
    expect(find.text(DateFormat.yMMMM().format(lastMonth)), findsOneWidget);
    expect(find.text('Top category: Travel'), findsOneWidget);
    // Each month offers its own advice; the tab's recap has one too.
    expect(find.text('AI advice'), findsNWidgets(2));

    // The calendar shows the tapped day's spending.
    expect(find.text('Tap a day to see what you spent'), findsOneWidget);
    await tester.tap(find.text('10').last);
    await tester.pumpAndSettle();
    expect(
      find.text('${DateFormat.MMMd().format(lastMonth)}: spent 20.00'),
      findsOneWidget,
    );
    await tester.tap(find.text('11').last);
    await tester.pumpAndSettle();
    expect(
      find.text(
        '${DateFormat.MMMd().format(lastMonth.add(const Duration(days: 1)))}'
        ': no spending',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text(DateFormat.yMMMM().format(twoMonthsAgo)), findsOneWidget);
    expect(find.text('Top category: Health'), findsOneWidget);
  });
}
