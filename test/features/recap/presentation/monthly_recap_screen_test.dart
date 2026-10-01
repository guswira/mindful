import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/recap/domain/monthly_recap.dart';
import 'package:mindful/features/recap/presentation/monthly_recap_providers.dart';
import 'package:mindful/features/recap/presentation/monthly_recap_screen.dart';
import 'package:mindful/features/recap/presentation/widgets/recap_slide.dart';

final _month = DateTime(2026, 9);

const _routines = RoutineRecap(
  activeHabits: 2,
  checkIns: 50,
  possibleCheckIns: 60,
  perfectDays: 20,
  longestStreak: 12,
  bestHabitName: 'Read',
  bestHabitIcon: '📚',
  bestHabitCheckIns: 28,
);

final _recap = MonthlyRecap(
  month: _month,
  isComplete: true,
  routines: _routines,
  tasks: const TaskRecap(completed: 9, added: 10, stillOpen: 1),
  cashflow: const CashflowRecap(
    currency: 'IDR',
    spending: 500000,
    income: 2000000,
    entryCount: 12,
    noSpendDays: 8,
    budget: 1000000,
    topCategory: 'Food',
    topCategoryAmount: 300000,
  ),
  ai: const AiRecap(scans: 0, totalCalories: 0),
);

Future<void> _pump(WidgetTester tester, {bool reduceMotion = true}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        monthlyRecapProvider(_month).overrideWith((ref) async => _recap),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GlassTheme.dark()]),
        // Skips the auto-advance timer and count-up, so the test steps
        // through slides by tapping only.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: MonthlyRecapScreen(month: _month),
      ),
    ),
  );
  if (reduceMotion) await tester.pumpAndSettle();
}

Future<void> _tapNext(WidgetTester tester) async {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  await tester.tapAt(Offset(size.width * 0.85, size.height / 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('steps through every slide, each ending on motivation', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byType(RecapSlide), findsOneWidget);
    expect(find.text('Your September'), findsOneWidget);

    await _tapNext(tester);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('83%'), findsOneWidget);
    expect(find.textContaining('Incredible consistency!'), findsOneWidget);

    await _tapNext(tester);
    expect(find.text('9'), findsOneWidget);
    expect(find.textContaining('You crushed your to-do list'), findsOneWidget);

    await _tapNext(tester);
    expect(find.text('IDR 500,000'), findsOneWidget);
    expect(find.textContaining('kept your spending in check'), findsOneWidget);

    await _tapNext(tester);
    expect(find.textContaining("Haven't tried the AI Lab"), findsOneWidget);

    await _tapNext(tester);
    expect(find.text('Keep going!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('tapping the left third goes back a slide', (tester) async {
    await _pump(tester);
    await _tapNext(tester);
    expect(find.text('50'), findsOneWidget);

    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width * 0.1, size.height / 2));
    await tester.pumpAndSettle();
    expect(find.text('Your September'), findsOneWidget);
  });

  testWidgets('auto-advances to the next slide after its duration', (
    tester,
  ) async {
    await _pump(tester, reduceMotion: false);
    await tester.pump();
    expect(find.text('Your September'), findsOneWidget);

    // Past the first slide's 7s (plus its page transition), well short of
    // the second slide's — stepped so every ticker gets its frames.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.text('ROUTINES'), findsOneWidget);
    expect(find.text('Your September'), findsNothing);
  });
}
