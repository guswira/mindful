import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/app_theme.dart';
import 'package:mindful/features/money/domain/budget_settings.dart';
import 'package:mindful/features/money/domain/budget_type.dart';
import 'package:mindful/features/money/presentation/budget_settings_sheet.dart';
import 'package:mindful/shared/widgets/tinted_pill.dart';

final _monthlySettings = BudgetSettings(
  id: 'b1',
  userId: 'u1',
  budgetType: BudgetType.monthly,
  amount: 1000,
  currency: 'EUR',
  updatedAt: DateTime(2026, 1, 1),
);

final _dailySettings = BudgetSettings(
  id: 'b2',
  userId: 'u1',
  budgetType: BudgetType.daily,
  amount: 100,
  currency: 'EUR',
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  Widget buildSheet({
    BudgetSettings? monthlySettings,
    BudgetSettings? dailySettings,
  }) => ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: BudgetSettingsSheet(
          monthlySettings: monthlySettings,
          dailySettings: dailySettings,
        ),
      ),
    ),
  );

  testWidgets(
    'shows both sections, defaulting to IDR, with independent save pills',
    (tester) async {
      await tester.pumpWidget(buildSheet());

      expect(find.text('Budget settings'), findsOneWidget);
      expect(find.text('Monthly budget'), findsOneWidget);
      expect(find.text('Daily budget'), findsOneWidget);
      expect(find.text('IDR'), findsNWidgets(2));
      expect(find.widgetWithText(TintedPill, 'Save monthly'), findsOneWidget);
      expect(find.widgetWithText(TintedPill, 'Save daily'), findsOneWidget);
    },
  );

  testWidgets('opening the currency picker lists the available currencies', (
    tester,
  ) async {
    // The default test surface is only 600 logical pixels tall — too short
    // for the picker's 10 plain (non-scrolling) ListTiles.
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSheet());

    await tester.tap(find.text('IDR').first);
    await tester.pumpAndSettle();

    expect(find.text('SGD'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('picking a currency updates both sections\' display', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSheet());

    await tester.tap(find.text('IDR').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD').last);
    await tester.pumpAndSettle();

    expect(find.text('USD'), findsNWidgets(2));
    expect(find.text('IDR'), findsNothing);
  });

  testWidgets('pre-fills each section from its own budget settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSheet(
        monthlySettings: _monthlySettings,
        dailySettings: _dailySettings,
      ),
    );

    expect(find.text('1.000'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('EUR'), findsNWidgets(2));
  });
}
