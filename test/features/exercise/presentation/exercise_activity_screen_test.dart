import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/core/theme/glass_theme.dart';
import 'package:mindful/features/exercise/data/breathing_session_repository.dart';
import 'package:mindful/features/exercise/presentation/exercise_activity_screen.dart';
import 'package:mindful/features/exercise/presentation/widgets/exercise_calendar_card.dart';
import 'package:mindful/features/exercise/presentation/widgets/exercise_stats_row.dart';

import '../exercise_fakes.dart';

void main() {
  testWidgets('shows totals from saved sessions and the calendar', (
    tester,
  ) async {
    final box = FakeBox();
    final now = DateTime.now();
    for (final (id, seconds) in [('a', 300), ('b', 120)]) {
      await box.put(
        id,
        testSession(id: id, startedAt: now, seconds: seconds).toJson(),
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breathingSessionRepositoryProvider.overrideWith(
            (ref) async => BreathingSessionRepository(
              box: box,
              datasource: FakeBreathingDatasource(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GlassTheme.dark()]),
          home: const ExerciseActivityScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise activity'), findsOneWidget);
    expect(find.byType(ExerciseCalendarCard), findsOneWidget);
    final stats = find.byType(ExerciseStatsRow);
    expect(
      find.descendant(of: stats, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stats, matching: find.text('7m')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stats, matching: find.text('1')),
      findsOneWidget,
    );
  });
}
