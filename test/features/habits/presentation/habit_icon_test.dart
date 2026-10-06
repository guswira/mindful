import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/habits/presentation/add_habit_sheet_icon_color.dart';
import 'package:mindful/features/habits/presentation/habit_icon.dart';

void main() {
  test('every preset has a flat icon', () {
    for (final emoji in habitSheetIconPresets) {
      expect(habitIconData(emoji), isNotNull, reason: emoji);
    }
  });

  test('matches with or without the U+FE0F variation selector', () {
    expect(habitIconData('❤️'), Icons.favorite_outline_rounded);
    expect(habitIconData('❤'), Icons.favorite_outline_rounded);
  });

  testWidgets('draws a preset as an icon and anything else as the emoji', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        home: const Scaffold(
          body: Column(
            children: [
              HabitIcon(icon: '🏃', color: Colors.teal),
              HabitIcon(icon: '🦄', color: Colors.teal),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.directions_run_rounded), findsOneWidget);
    expect(find.text('🦄'), findsOneWidget);
  });
}
