import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_action.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/habits/presentation/habit_day_log_sheet.dart';

Habit _habit(List<HabitAction> actions) => Habit(
  id: 'h1',
  userId: 'u1',
  name: 'Workout',
  icon: '🏋️',
  color: '#FF0000',
  createdAt: DateTime(2026),
  actions: actions,
);

HabitLog _log(String? actionId) => HabitLog(
  id: 'l1',
  userId: 'u1',
  habitId: 'h1',
  date: DateTime(2026, 3, 15),
  completedActionId: actionId,
);

void main() {
  const gym = HabitAction(id: 'a1', label: 'Gym');

  test('a habit without actions offers not done / done', () {
    expect(habitDayChoices(_habit(const []), null), [
      habitDayNotDone,
      (done: true, actionId: null),
    ]);
  });

  test('a habit with actions offers each action, not plain done', () {
    expect(habitDayChoices(_habit(const [gym]), null), [
      habitDayNotDone,
      (done: true, actionId: 'a1'),
    ]);
  });

  test('keeps a plain-done or removed-action log selectable', () {
    expect(habitDayChoices(_habit(const [gym]), _log(null)), [
      habitDayNotDone,
      (done: true, actionId: null),
      (done: true, actionId: 'a1'),
    ]);
    expect(habitDayChoices(_habit(const [gym]), _log('gone')), [
      habitDayNotDone,
      (done: true, actionId: 'a1'),
      (done: true, actionId: 'gone'),
    ]);
  });
}
