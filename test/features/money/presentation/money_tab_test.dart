import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindfull/core/theme/glass_theme.dart';
import 'package:mindfull/features/money/data/money_repository.dart';
import 'package:mindfull/features/money/domain/budget_settings.dart';
import 'package:mindfull/features/money/domain/budget_type.dart';
import 'package:mindfull/features/money/presentation/money_tab.dart';

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

  testWidgets('no budget set shows the "Set your budget" prompt', (
    tester,
  ) async {
    await tester.pumpWidget(buildTab());
    await tester.pumpAndSettle();

    expect(find.text('Set your budget to get started'), findsOneWidget);
    expect(find.text('Set budget'), findsOneWidget);
  });

  testWidgets(
    'only a monthly budget set shows its gauge and a ghost daily card',
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
      expect(find.text('Daily budget'), findsOneWidget);
      expect(find.text('Set Daily'), findsOneWidget);
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
  });
}
