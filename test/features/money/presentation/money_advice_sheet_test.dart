import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/app_theme.dart';
import 'package:mindfull/features/money/domain/money_advice.dart';
import 'package:mindfull/features/money/presentation/money_advice_sheet.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(body: child),
  );

  testWidgets('shows the summary, insights, tips and disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const MoneyAdviceSheet(
          advice: MoneyAdvice(
            summary: 'Mostly food.',
            spendingInsights: ['Food is 100% of spending.'],
            savingTips: ['Cook at home.'],
          ),
        ),
      ),
    );

    expect(find.text('AI spending advice'), findsOneWidget);
    expect(find.text('Mostly food.'), findsOneWidget);
    expect(find.text('Food is 100% of spending.'), findsOneWidget);
    expect(find.text('Cook at home.'), findsOneWidget);
    expect(find.textContaining('not financial advice'), findsOneWidget);
  });

  testWidgets('loading sheet shows a spinner and status text', (tester) async {
    await tester.pumpWidget(wrap(const MoneyAdviceLoadingSheet()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Looking at your spending...'), findsOneWidget);
  });
}
