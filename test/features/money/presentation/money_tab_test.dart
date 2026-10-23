import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/money/data/money_repository.dart';
import 'package:mindful/features/money/domain/budget_settings.dart';
import 'package:mindful/features/money/domain/budget_type.dart';
import 'package:mindful/features/money/presentation/money_tab.dart';

class _MockBox extends Mock implements Box<dynamic> {}

void main() {
  late _MockBox entriesBox;
  late _MockBox settingsBox;

  setUp(() {
    entriesBox = _MockBox();
    settingsBox = _MockBox();
    when(() => entriesBox.values).thenReturn(const <dynamic>[]);
    when(() => settingsBox.get('settings_monthly')).thenReturn(null);
    when(() => settingsBox.get('settings_daily')).thenReturn(null);
  });

  Widget buildTab() => ProviderScope(
    overrides: [
      moneyRepositoryProvider.overrideWith(
        (ref) async =>
            MoneyRepository(entriesBox: entriesBox, settingsBox: settingsBox),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [GlassTheme.dark()]),
      home: const MoneyTab(),
    ),
  );

  testWidgets('no budget or entries yet shows both intros', (tester) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Set a budget'), findsOneWidget);
    expect(find.text('Set budget'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Record your spending'), 200);
    expect(find.text('Record spending'), findsOneWidget);
    // Nothing to filter yet, so the period pills stay hidden.
    expect(find.text('This Week'), findsNothing);
  });

  testWidgets(
    'only a monthly budget set shows it plus a link to set the rest',
    (tester) async {
      final settings = BudgetSettings(
        id: 'b1',
        userId: 'u1',
        budgetType: BudgetType.monthly,
        amount: 1000,
        currency: 'USD',
        updatedAt: DateTime(2026, 1, 1),
      );
      when(
        () => settingsBox.get('settings_monthly'),
      ).thenReturn(settings.toJson());

      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Daily · Weekly · Yearly'), findsOneWidget);
      // One gear for the whole card, not one per budget.
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    },
  );

  testWidgets('both budgets set shows two gauge cards', (tester) async {
    final monthly = BudgetSettings(
      id: 'b1',
      userId: 'u1',
      budgetType: BudgetType.monthly,
      amount: 1000,
      currency: 'USD',
      updatedAt: DateTime(2026, 1, 1),
    );
    final daily = BudgetSettings(
      id: 'b2',
      userId: 'u1',
      budgetType: BudgetType.daily,
      amount: 50,
      currency: 'USD',
      updatedAt: DateTime(2026, 1, 1),
    );
    when(
      () => settingsBox.get('settings_monthly'),
    ).thenReturn(monthly.toJson());
    when(() => settingsBox.get('settings_daily')).thenReturn(daily.toJson());

    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.textContaining('of USD 1,000'), findsOneWidget);
    expect(find.textContaining('of USD 50'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('a yearly budget gets its own gauge', (tester) async {
    final yearly = BudgetSettings(
      id: 'b3',
      userId: 'u1',
      budgetType: BudgetType.yearly,
      amount: 12000,
      currency: 'USD',
      updatedAt: DateTime(2026, 1, 1),
    );
    when(() => settingsBox.get('settings_yearly')).thenReturn(yearly.toJson());

    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Yearly'), findsOneWidget);
    expect(find.textContaining('of USD 12,000'), findsOneWidget);
    expect(find.text('Daily · Weekly · Monthly'), findsOneWidget);
  });

  testWidgets('more than two budgets collapse behind "Show more"', (
    tester,
  ) async {
    BudgetSettings budget(BudgetType type, double amount) => BudgetSettings(
      id: type.name,
      userId: 'u1',
      budgetType: type,
      amount: amount,
      currency: 'USD',
      updatedAt: DateTime(2026, 1, 1),
    );
    for (final (type, amount) in [
      (BudgetType.daily, 50.0),
      (BudgetType.weekly, 300.0),
      (BudgetType.monthly, 1000.0),
      (BudgetType.yearly, 12000.0),
    ]) {
      when(
        () => settingsBox.get('settings_${type.name}'),
      ).thenReturn(budget(type, amount).toJson());
    }

    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsNothing);
    expect(find.text('Yearly'), findsNothing);

    await tester.tap(find.text('Show 2 more'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();
    expect(find.text('Yearly'), findsNothing);
  });
}
