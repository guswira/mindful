import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindfull/core/theme/app_theme.dart';
import 'package:mindfull/features/ai/domain/food_analysis.dart';
import 'package:mindfull/features/ai/presentation/food_result_sheet.dart';

const _analysis = FoodAnalysis(
  foodName: 'Grilled Chicken Salad',
  calories: 420,
  protein: 35,
  carbs: 12,
  fat: 18,
  fiber: 4,
  confidence: 'high',
  servingNote: '1 bowl (approx. 350g)',
  healthNote: 'A good source of lean protein.',
  ingredients: ['Chicken breast', 'Lettuce', 'Tomato'],
);

void main() {
  Widget buildSheet({
    FoodAnalysis analysis = _analysis,
    VoidCallback? onSave,
  }) => MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(
      body: FoodResultSheet(analysis: analysis, onSave: onSave),
    ),
  );

  testWidgets('shows the food name, calories, macros and ingredients', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('Grilled Chicken Salad'), findsOneWidget);
    expect(find.text('420'), findsOneWidget);
    expect(find.text('✓ Confident'), findsOneWidget);
    expect(find.text('35.0g'), findsOneWidget);
    expect(find.text('Chicken breast'), findsOneWidget);
    expect(find.text('A good source of lean protein.'), findsOneWidget);
  });

  testWidgets('with onSave shows Discard and Save scan actions', (
    tester,
  ) async {
    var saved = false;
    await tester.pumpWidget(buildSheet(onSave: () => saved = true));

    expect(find.text('Discard'), findsOneWidget);
    expect(find.text('Save scan'), findsOneWidget);
    expect(find.text('Dismiss'), findsNothing);

    await tester.tap(find.text('Save scan'));
    expect(saved, isTrue);
  });

  testWidgets('with no onSave shows only Dismiss (read-only history view)', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet());

    expect(find.text('Dismiss'), findsOneWidget);
    expect(find.text('Save scan'), findsNothing);
    expect(find.text('Discard'), findsNothing);
  });

  testWidgets('low confidence shows the extra warning message', (tester) async {
    await tester.pumpWidget(
      buildSheet(analysis: _analysis.copyWith(confidence: 'low')),
    );

    expect(find.text('! Uncertain'), findsOneWidget);
    expect(
      find.text('Low confidence — try a clearer, closer photo.'),
      findsOneWidget,
    );
  });
}
