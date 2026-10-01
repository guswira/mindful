import '../../ai/domain/food_scan.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_log.dart';
import '../../money/domain/entry_type.dart';
import '../../money/domain/money_entry.dart';
import '../../tasks/domain/task.dart';
import 'monthly_recap.dart';

/// Computes [month]'s recap from already-loaded data. Pure, so the stats
/// can be tested without Hive or Supabase.
///
/// Only days up to [now] count for a month still in progress — a habit
/// isn't "missed" on a day that hasn't happened yet.
MonthlyRecap buildMonthlyRecap({
  required DateTime month,
  required DateTime now,
  required List<Habit> habits,
  required List<HabitLog> habitLogs,
  required List<Task> tasks,
  required List<MoneyEntry> moneyEntries,
  required String currency,
  double? monthlyBudget,
  List<FoodScan>? foodScans,
}) {
  final start = DateTime(month.year, month.month);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final today = _dateOnly(now);
  final lastDay = today.isBefore(monthEnd) ? today : monthEnd;

  return MonthlyRecap(
    month: start,
    isComplete: today.isAfter(monthEnd),
    routines: _routines(start, lastDay, habits, habitLogs),
    tasks: _tasks(start, monthEnd, lastDay, tasks),
    cashflow: _cashflow(start, lastDay, moneyEntries, currency, monthlyBudget),
    ai: foodScans == null ? null : _ai(start, monthEnd, foodScans),
  );
}

RoutineRecap _routines(
  DateTime start,
  DateTime lastDay,
  List<Habit> habits,
  List<HabitLog> logs,
) {
  final active = [
    for (final habit in habits)
      if (!habit.archived && !_dateOnly(habit.createdAt).isAfter(lastDay))
        habit,
  ];
  final days = <DateTime>[
    for (var d = start; !d.isAfter(lastDay); d = _nextDay(d)) d,
  ];

  final logDays = <String, Set<DateTime>>{
    for (final habit in active) habit.id: {},
  };
  for (final log in logs) {
    final day = _dateOnly(log.date);
    if (day.isBefore(start) || day.isAfter(lastDay)) continue;
    logDays[log.habitId]?.add(day);
  }

  var possible = 0;
  var perfectDays = 0;
  for (final day in days) {
    final existing = active.where((h) => !_dateOnly(h.createdAt).isAfter(day));
    possible += existing.length;
    if (existing.isNotEmpty &&
        existing.every((h) => logDays[h.id]!.contains(day))) {
      perfectDays++;
    }
  }

  Habit? best;
  var bestCount = 0;
  var longestStreak = 0;
  for (final habit in active) {
    // Every active habit got an entry in logDays above.
    final habitDays = logDays[habit.id]!;
    if (habitDays.length > bestCount) {
      best = habit;
      bestCount = habitDays.length;
    }
    var run = 0;
    for (final day in days) {
      run = habitDays.contains(day) ? run + 1 : 0;
      if (run > longestStreak) longestStreak = run;
    }
  }

  return RoutineRecap(
    activeHabits: active.length,
    checkIns: logDays.values.fold(0, (sum, set) => sum + set.length),
    possibleCheckIns: possible,
    perfectDays: perfectDays,
    longestStreak: longestStreak,
    bestHabitName: best?.name,
    bestHabitIcon: best?.icon,
    bestHabitCheckIns: bestCount,
  );
}

TaskRecap _tasks(
  DateTime start,
  DateTime monthEnd,
  DateTime lastDay,
  List<Task> tasks,
) {
  bool inMonth(DateTime date) => _inRange(_dateOnly(date), start, monthEnd);
  return TaskRecap(
    completed: tasks.where((t) => t.isCompleted && inMonth(t.updatedAt)).length,
    added: tasks.where((t) => inMonth(t.createdAt)).length,
    stillOpen: tasks.where((t) {
      final due = t.dueDate;
      return !t.isCompleted && due != null && !_dateOnly(due).isAfter(lastDay);
    }).length,
  );
}

CashflowRecap _cashflow(
  DateTime start,
  DateTime lastDay,
  List<MoneyEntry> entries,
  String currency,
  double? monthlyBudget,
) {
  final inMonth = entries
      .where((e) => _inRange(_dateOnly(e.date), start, lastDay))
      .toList();
  var spending = 0.0;
  var income = 0.0;
  final byCategory = <String, double>{};
  final spendDays = <DateTime>{};
  for (final entry in inMonth) {
    switch (entry.type) {
      case EntryType.spending:
        spending += entry.amount;
        byCategory.update(
          entry.category,
          (total) => total + entry.amount,
          ifAbsent: () => entry.amount,
        );
        spendDays.add(_dateOnly(entry.date));
      case EntryType.income:
        income += entry.amount;
    }
  }
  final top = byCategory.entries.isEmpty
      ? null
      : byCategory.entries.reduce((a, b) => b.value > a.value ? b : a);
  return CashflowRecap(
    currency: currency,
    spending: spending,
    income: income,
    entryCount: inMonth.length,
    noSpendDays: lastDay.difference(start).inDays + 1 - spendDays.length,
    budget: (monthlyBudget ?? 0) > 0 ? monthlyBudget : null,
    topCategory: top?.key,
    topCategoryAmount: top?.value ?? 0,
  );
}

AiRecap _ai(DateTime start, DateTime monthEnd, List<FoodScan> scans) {
  final inMonth = scans
      .where((s) => _inRange(_dateOnly(s.scannedAt.toLocal()), start, monthEnd))
      .toList();
  final foodCounts = <String, int>{};
  for (final scan in inMonth) {
    final name = scan.foodName;
    if (name == null || name.isEmpty) continue;
    foodCounts.update(name, (count) => count + 1, ifAbsent: () => 1);
  }
  final top = foodCounts.entries.isEmpty
      ? null
      : foodCounts.entries.reduce((a, b) => b.value > a.value ? b : a);
  return AiRecap(
    scans: inMonth.length,
    totalCalories: inMonth.fold(0, (sum, s) => sum + (s.calories ?? 0)),
    topFood: top?.key,
  );
}

bool _inRange(DateTime day, DateTime start, DateTime end) =>
    !day.isBefore(start) && !day.isAfter(end);

// Calendar arithmetic rather than adding a Duration, so DST changes can't
// skip or repeat a day.
DateTime _nextDay(DateTime day) => DateTime(day.year, day.month, day.day + 1);

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
