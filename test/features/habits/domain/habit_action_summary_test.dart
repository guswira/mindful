import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_action_summary.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/domain/habit_tag.dart';

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

const _heavy = HabitTag(id: 't1', label: 'Heavy');
const _easy = HabitTag(id: 't2', label: 'Easy');

HabitLog _log(
  DateTime date,
  String? actionId, {
  String habitId = 'h1',
  Map<String, int>? tags,
}) => HabitLog(
  id: '$habitId-$date',
  userId: 'u1',
  habitId: habitId,
  date: date,
  completedActionId: actionId,
  tags: tags,
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

  group('tags', () {
    final tagged = _habit.copyWith(tags: const [_heavy, _easy]);
    final logs = [
      _log(DateTime(2026, 3, 1), 'a1', tags: {'t1': 1, 't2': 3}),
      _log(DateTime(2026, 3, 2), 'a1', tags: {'t2': 1}),
      _log(DateTime(2026, 3, 3), 'a2', tags: {'t1': 2, 'gone': 5}),
      _log(DateTime(2026, 3, 4), 'a2'), // untagged
      _log(DateTime(2026, 2, 28), 'a1', tags: {'t1': 9}), // other month
      _log(DateTime(2026, 3, 5), 'a1', habitId: 'h2', tags: {'t1': 9}),
    ];

    test('sums each tag\'s counts in the month, keeping zero rows', () {
      expect(countTagsInMonth(tagged, logs, DateTime(2026, 3)), [
        (tag: _heavy, count: 3),
        (tag: _easy, count: 4),
      ]);
      expect(countTagsInMonth(tagged, const [], DateTime(2026, 3)), [
        (tag: _heavy, count: 0),
        (tag: _easy, count: 0),
      ]);
    });

    test('splits tag counts by action', () {
      expect(countTagsByActionInMonth(tagged, logs, DateTime(2026, 3)), {
        'a1': [(tag: _heavy, count: 1), (tag: _easy, count: 4)],
        'a2': [(tag: _heavy, count: 2), (tag: _easy, count: 0)],
      });
    });

    test('a habit without tags has no tag rows', () {
      expect(countTagsInMonth(_habit, logs, DateTime(2026, 3)), isEmpty);
    });
  });
}
