import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/ai/domain/food_scan.dart';
import 'package:mindful/features/habits/domain/habit.dart';
import 'package:mindful/features/habits/domain/habit_log.dart';
import 'package:mindful/features/money/domain/entry_type.dart';
import 'package:mindful/features/money/domain/money_entry.dart';
import 'package:mindful/features/recap/domain/monthly_recap.dart';
import 'package:mindful/features/recap/domain/monthly_recap_builder.dart';
import 'package:mindful/features/tasks/domain/task.dart';

Habit _habit(String id, DateTime createdAt, {bool archived = false}) => Habit(
  id: id,
  userId: 'u',
  name: 'Habit $id',
  icon: '🔥',
  color: '#A78BFA',
  createdAt: createdAt,
  archived: archived,
);

HabitLog _log(String habitId, int day) => HabitLog(
  id: '$habitId-$day',
  userId: 'u',
  habitId: habitId,
  date: DateTime(2026, 9, day),
);

Task _task(
  String id, {
  required DateTime createdAt,
  DateTime? updatedAt,
  bool done = false,
  DateTime? due,
}) => Task(
  id: id,
  userId: 'u',
  name: id,
  createdAt: createdAt,
  updatedAt: updatedAt ?? createdAt,
  isCompleted: done,
  dueDate: due,
);

MoneyEntry _money(EntryType type, double amount, String category, int day) =>
    MoneyEntry(
      id: '$type-$category-$day',
      userId: 'u',
      type: type,
      amount: amount,
      category: category,
      date: DateTime(2026, 9, day),
      createdAt: DateTime(2026, 9, day),
      updatedAt: DateTime(2026, 9, day),
    );

void main() {
  final september = DateTime(2026, 9);
  final afterSeptember = DateTime(2026, 10, 2);

  MonthlyRecap build({
    DateTime? now,
    List<Habit> habits = const [],
    List<HabitLog> logs = const [],
    List<Task> tasks = const [],
    List<MoneyEntry> money = const [],
    double? budget,
    List<FoodScan>? scans = const [],
  }) => buildMonthlyRecap(
    month: september,
    now: now ?? afterSeptember,
    habits: habits,
    habitLogs: logs,
    tasks: tasks,
    moneyEntries: money,
    currency: 'IDR',
    monthlyBudget: budget,
    foodScans: scans,
  );

  test('an empty month is all zeros with empty tones', () {
    final recap = build();
    expect(recap.isComplete, isTrue);
    expect(recap.routines.tone, RecapTone.empty);
    expect(recap.tasks.tone, RecapTone.empty);
    expect(recap.cashflow.tone, RecapTone.empty);
    expect(recap.ai?.tone, RecapTone.empty);
    expect(recap.cashflow.noSpendDays, 30);
  });

  test('routines count check-ins only from the day each habit existed', () {
    final recap = build(
      habits: [
        _habit('a', DateTime(2026, 8, 1)),
        // Created on the 21st: 10 possible days, not 30.
        _habit('b', DateTime(2026, 9, 21)),
        _habit('archived', DateTime(2026, 8, 1), archived: true),
      ],
      logs: [
        for (var day = 1; day <= 30; day++) _log('a', day),
        for (var day = 21; day <= 30; day++) _log('b', day),
        _log('archived', 5),
      ],
    );
    final routines = recap.routines;
    expect(routines.activeHabits, 2);
    expect(routines.checkIns, 40);
    expect(routines.possibleCheckIns, 40);
    expect(routines.perfectDays, 30);
    expect(routines.longestStreak, 30);
    expect(routines.bestHabitName, 'Habit a');
    expect(routines.tone, RecapTone.great);
  });

  test('a month in progress only counts days up to today', () {
    final recap = build(
      now: DateTime(2026, 9, 10),
      habits: [_habit('a', DateTime(2026, 8, 1))],
      logs: [_log('a', 1), _log('a', 2), _log('a', 5)],
    );
    expect(recap.isComplete, isFalse);
    expect(recap.routines.possibleCheckIns, 10);
    expect(recap.routines.longestStreak, 2);
    expect(recap.routines.tone, RecapTone.starting);
  });

  test('tasks count completions, additions and what is still open', () {
    final recap = build(
      tasks: [
        _task(
          'done',
          createdAt: DateTime(2026, 9, 2),
          updatedAt: DateTime(2026, 9, 3),
          done: true,
        ),
        _task(
          'done-in-august',
          createdAt: DateTime(2026, 8, 2),
          updatedAt: DateTime(2026, 8, 3),
          done: true,
        ),
        _task(
          'overdue',
          createdAt: DateTime(2026, 9, 4),
          due: DateTime(2026, 9, 20),
        ),
        _task(
          'due-next-month',
          createdAt: DateTime(2026, 9, 4),
          due: DateTime(2026, 10, 20),
        ),
      ],
    );
    expect(recap.tasks.completed, 1);
    expect(recap.tasks.added, 3);
    expect(recap.tasks.stillOpen, 1);
    expect(recap.tasks.tone, RecapTone.good);
  });

  test('cashflow sums the month, finds the top category and budget use', () {
    final recap = build(
      budget: 1000,
      money: [
        _money(EntryType.spending, 300, 'Food', 1),
        _money(EntryType.spending, 200, 'Food', 2),
        _money(EntryType.spending, 100, 'Transport', 2),
        _money(EntryType.income, 2000, 'Salary', 25),
      ],
    );
    final cashflow = recap.cashflow;
    expect(cashflow.spending, 600);
    expect(cashflow.income, 2000);
    expect(cashflow.net, 1400);
    expect(cashflow.topCategory, 'Food');
    expect(cashflow.topCategoryAmount, 500);
    expect(cashflow.noSpendDays, 28);
    expect(cashflow.underBudget, isTrue);
    expect(cashflow.tone, RecapTone.great);
  });

  test('AI recap averages calories and is null when scans failed to load', () {
    final scans = [
      for (final (i, name) in ['Nasi goreng', 'Nasi goreng', 'Salad'].indexed)
        FoodScan(
          id: '$i',
          userId: 'u',
          scannedAt: DateTime(2026, 9, 10 + i),
          foodName: name,
          calories: 300 + i * 100,
        ),
      FoodScan(
        id: 'old',
        userId: 'u',
        scannedAt: DateTime(2026, 8, 31),
        calories: 999,
      ),
    ];
    final ai = build(scans: scans).ai;
    expect(ai?.scans, 3);
    expect(ai?.totalCalories, 1200);
    expect(ai?.averageCalories, 400);
    expect(ai?.topFood, 'Nasi goreng');

    expect(build(scans: null).ai, isNull);
  });
}
