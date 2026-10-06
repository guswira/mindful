/// How well a recap slide's month went — picks that slide's motivation
/// line, so a quiet month gets encouragement instead of a scolding.
enum RecapTone { great, good, starting, empty }

/// One month's routines, tasks, cashflow and AI usage, shown by
/// [MonthlyRecapScreen]. Transient — computed on demand, never stored.
class MonthlyRecap {
  const MonthlyRecap({
    required this.month,
    required this.isComplete,
    required this.routines,
    required this.tasks,
    required this.cashflow,
    required this.ai,
  });

  /// The 1st of the recapped month.
  final DateTime month;

  /// False while [month] is still the current month — the copy then says
  /// "so far" rather than treating the month as finished.
  final bool isComplete;

  final RoutineRecap routines;
  final TaskRecap tasks;
  final CashflowRecap cashflow;

  /// Null when the scans couldn't be loaded (they live in Supabase only,
  /// with no offline cache).
  final AiRecap? ai;
}

/// Habit check-ins over the month.
class RoutineRecap {
  const RoutineRecap({
    required this.activeHabits,
    required this.checkIns,
    required this.possibleCheckIns,
    required this.perfectDays,
    required this.longestStreak,
    this.bestHabitName,
    this.bestHabitCheckIns = 0,
  });

  final int activeHabits;
  final int checkIns;

  /// One per habit per day it existed in the month, up to today.
  final int possibleCheckIns;

  /// Days on which every habit that existed that day was checked in.
  final int perfectDays;

  /// Longest run of consecutive days any single habit was checked in.
  final int longestStreak;

  final String? bestHabitName;
  final int bestHabitCheckIns;

  /// 0.0–1.0; 0 when there was nothing to check in.
  double get completionRate =>
      possibleCheckIns == 0 ? 0 : checkIns / possibleCheckIns;

  RecapTone get tone => switch (completionRate) {
    _ when activeHabits == 0 => RecapTone.empty,
    >= 0.8 => RecapTone.great,
    >= 0.5 => RecapTone.good,
    _ => RecapTone.starting,
  };
}

/// Tasks added and finished over the month.
class TaskRecap {
  const TaskRecap({
    required this.completed,
    required this.added,
    required this.stillOpen,
  });

  /// Completed tasks last touched this month — tasks have no completion
  /// timestamp, so `updated_at` stands in for it.
  final int completed;

  final int added;

  /// Unfinished tasks due by the end of the month (or by today, for a
  /// month still in progress), including ones carried over from before.
  final int stillOpen;

  /// 0.0–1.0 share of this month's tasks that got done.
  double get completionRate {
    final total = completed + stillOpen;
    return total == 0 ? 0 : completed / total;
  }

  RecapTone get tone => switch (completionRate) {
    _ when completed == 0 && stillOpen == 0 && added == 0 => RecapTone.empty,
    >= 0.8 => RecapTone.great,
    >= 0.5 => RecapTone.good,
    _ => RecapTone.starting,
  };
}

/// Spending vs income over the month.
class CashflowRecap {
  const CashflowRecap({
    required this.currency,
    required this.spending,
    required this.income,
    required this.entryCount,
    required this.noSpendDays,
    this.budget,
    this.topCategory,
    this.topCategoryAmount = 0,
  });

  final String currency;
  final double spending;
  final double income;
  final int entryCount;

  /// Days so far this month with no spending logged.
  final int noSpendDays;

  /// The monthly budget, if one is set.
  final double? budget;

  /// Stored (English) spending category name with the largest total.
  final String? topCategory;
  final double topCategoryAmount;

  double get net => income - spending;

  bool get underBudget => budget != null && spending <= budget!;

  RecapTone get tone => switch (entryCount) {
    0 => RecapTone.empty,
    _ when underBudget || (budget == null && net >= 0) => RecapTone.great,
    _ when net >= 0 => RecapTone.good,
    _ => RecapTone.starting,
  };
}

/// Food scans run through the AI Lab over the month.
class AiRecap {
  const AiRecap({
    required this.scans,
    required this.totalCalories,
    this.topFood,
  });

  final int scans;
  final int totalCalories;

  /// The most often scanned food name.
  final String? topFood;

  int get averageCalories => scans == 0 ? 0 : (totalCalories / scans).round();

  RecapTone get tone => switch (scans) {
    0 => RecapTone.empty,
    >= 10 => RecapTone.great,
    >= 4 => RecapTone.good,
    _ => RecapTone.starting,
  };
}
