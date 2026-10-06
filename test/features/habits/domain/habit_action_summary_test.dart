import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_action_summary.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';

const _gym = HabitAction(id: 'a1', label: 'Gym');
const _run = HabitAction(id: 'a2', label: 'Run');

final _habit = Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026, 1, 1),
  actions: const [_gym, _run],
);

HabitLog _log(DateTime date, String? actionId, {String habitId = 'h1'}) =>
    HabitLog(
      id: '$habitId-$date',
      userId: 'u1',
      habitId: habitId,
      date: date,
      completedActionId: actionId,
    );

void main() {
  test('counts each action in the month, keeping zero-count actions', () {
    final counts = countActionsInMonth(_habit, [
      _log(DateTime(2026, 3, 1), 'a1'),
      _log(DateTime(2026, 3, 2), 'a1'),
      _log(DateTime(2026, 2, 28), 'a2'), // other month
      _log(DateTime(2026, 3, 3), 'a2', habitId: 'h2'), // other habit
    ], DateTime(2026, 3));

    expect(counts, [
      (kind: HabitActionCountKind.action, action: _gym, count: 2),
      (kind: HabitActionCountKind.action, action: _run, count: 0),
    ]);
  });

  test('adds plain-done and removed-action rows only when present', () {
    final counts = countActionsInMonth(_habit, [
      _log(DateTime(2026, 3, 1), null),
      _log(DateTime(2026, 3, 2), 'gone'),
      _log(DateTime(2026, 3, 3), 'also-gone'),
    ], DateTime(2026, 3));

    expect(counts.skip(2), [
      (kind: HabitActionCountKind.plainDone, action: null, count: 1),
      (kind: HabitActionCountKind.removed, action: null, count: 2),
    ]);
  });

  test('actionForLog finds the logged action, or null', () {
    expect(actionForLog(_habit, _log(DateTime(2026, 3, 1), 'a2')), _run);
    expect(actionForLog(_habit, _log(DateTime(2026, 3, 1), null)), isNull);
    expect(actionForLog(_habit, _log(DateTime(2026, 3, 1), 'gone')), isNull);
  });
}
