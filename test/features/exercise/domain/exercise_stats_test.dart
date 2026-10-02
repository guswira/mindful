import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/exercise/domain/exercise_stats.dart';

import '../exercise_fakes.dart';

void main() {
  final now = DateTime(2026, 10, 15, 9);

  test('no sessions is all zeros', () {
    final stats = buildExerciseStats(const [], now);

    expect(stats.totalSessions, 0);
    expect(stats.totalTime, Duration.zero);
    expect(stats.currentStreak, 0);
    expect(stats.byDay, isEmpty);
  });

  test('totals sessions and time, grouped by local day', () {
    final stats = buildExerciseStats([
      testSession(id: 'a', startedAt: DateTime(2026, 10, 15, 7), seconds: 120),
      testSession(id: 'b', startedAt: DateTime(2026, 10, 15, 8), seconds: 60),
      testSession(id: 'c', startedAt: DateTime(2026, 9, 30, 21), seconds: 30),
    ], now);

    expect(stats.totalSessions, 3);
    expect(stats.totalTime, const Duration(seconds: 210));
    final today = stats.byDay[DateTime(2026, 10, 15)];
    expect(today?.sessions, 2);
    expect(today?.time, const Duration(minutes: 3));
    expect(stats.monthActivity(DateTime(2026, 10)).sessions, 2);
    expect(stats.monthActivity(DateTime(2026, 9)).time.inSeconds, 30);
  });

  test('streak counts back from yesterday when today has no session', () {
    final stats = buildExerciseStats([
      testSession(id: 'a', startedAt: DateTime(2026, 10, 14, 7)),
      testSession(id: 'b', startedAt: DateTime(2026, 10, 13, 7)),
      testSession(id: 'c', startedAt: DateTime(2026, 10, 11, 7)),
    ], now);

    expect(stats.currentStreak, 2);
  });

  test('a gap before yesterday ends the streak', () {
    final stats = buildExerciseStats([
      testSession(id: 'a', startedAt: DateTime(2026, 10, 13, 7)),
    ], now);

    expect(stats.currentStreak, 0);
  });
}
