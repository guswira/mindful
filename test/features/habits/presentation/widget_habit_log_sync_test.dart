import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/presentation/widget_habit_log_sync.dart';

void main() {
  group('parsePendingWidgetHabitLogs', () {
    test('reads checks, action picks and undos in order', () {
      final logs = parsePendingWidgetHabitLogs('''
        [
          {"habitId": "h1", "date": "2026-10-03"},
          {"habitId": "h2", "date": "2026-10-04", "actionLabel": "Gym"},
          {"habitId": "h1", "date": "2026-10-04", "undo": true}
        ]
      ''');

      expect(logs, hasLength(3));
      expect(logs[0].habitId, 'h1');
      expect(logs[0].date, DateTime(2026, 10, 3));
      expect(logs[0].actionLabel, isNull);
      expect(logs[0].undo, isFalse);
      expect(logs[1].actionLabel, 'Gym');
      expect(logs[2].undo, isTrue);
    });

    test('skips malformed entries but keeps the rest', () {
      final logs = parsePendingWidgetHabitLogs('''
        [
          {"habitId": "h1"},
          {"habitId": 3, "date": "2026-10-04"},
          {"habitId": "h2", "date": "not a date"},
          "junk",
          {"habitId": "h3", "date": "2026-10-04"}
        ]
      ''');

      expect(logs.map((log) => log.habitId), ['h3']);
    });

    test('returns nothing for a missing or broken queue', () {
      expect(parsePendingWidgetHabitLogs(null), isEmpty);
      expect(parsePendingWidgetHabitLogs(''), isEmpty);
      expect(parsePendingWidgetHabitLogs('{not json'), isEmpty);
      expect(parsePendingWidgetHabitLogs('{"habitId": "h1"}'), isEmpty);
    });
  });

  group('habitActionByLabel', () {
    final habit = Habit(
      id: 'h1',
      userId: 'u1',
      name: 'Workout',
      icon: '🏋️',
      color: '#FF0000',
      createdAt: DateTime(2026),
      actions: const [
        HabitAction(id: 'a1', label: 'Gym'),
        HabitAction(id: 'a2', label: 'Run'),
      ],
    );

    test('finds the action with that label', () {
      expect(habitActionByLabel(habit, 'Run')?.id, 'a2');
    });

    test('falls back to plain done for null or unknown labels', () {
      expect(habitActionByLabel(habit, null), isNull);
      expect(habitActionByLabel(habit, 'Swim'), isNull);
    });
  });
}
