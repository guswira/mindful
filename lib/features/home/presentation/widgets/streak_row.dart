import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../habits/presentation/habit_tab.dart';
import '../../../journal/data/journal_entries_controller.dart';
import '../../../journal/domain/journal_entry.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/task_tab.dart';

part 'streak_row.g.dart';

/// Home screen streak counts: consecutive journaling days, today's habit
/// completion, and tasks due today or overdue.
typedef HomeStreakSummary = ({
  int journalStreak,
  int habitsDone,
  int habitsTotal,
  int tasksDue,
});

/// Computes [HomeStreakSummary] from the journal, habit and task
/// controllers already loaded elsewhere on the home tab.
@riverpod
HomeStreakSummary homeStreakSummary(Ref ref) {
  final entries = ref.watch(journalEntriesProvider).valueOrNull ?? const [];
  final habits = ref.watch(habitTabControllerProvider).valueOrNull ?? const [];
  final tasks = ref.watch(taskTabControllerProvider).valueOrNull ?? const [];

  return (
    journalStreak: _journalStreak(entries),
    habitsDone: habits.where((item) => item.todayLog != null).length,
    habitsTotal: habits.length,
    tasksDue: _tasksDueCount(tasks),
  );
}

/// The number of consecutive days with a journal entry, counting back from
/// today — or from yesterday if today's entry hasn't been written yet, so
/// the streak doesn't drop to zero before the day is over.
int _journalStreak(List<JournalEntry> entries) {
  final days = {
    for (final entry in entries)
      DateTime(entry.date.year, entry.date.month, entry.date.day),
  };
  var cursor = _today();
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int _tasksDueCount(List<Task> tasks) {
  final today = _today();
  return tasks
      .where(
        (task) =>
            !task.isCompleted &&
            task.dueDate != null &&
            !_dateOnly(task.dueDate!).isAfter(today),
      )
      .length;
}

DateTime _today() => _dateOnly(DateTime.now());

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Three equal glass cards: journal streak, habits done today, tasks due.
class StreakRow extends ConsumerWidget {
  const StreakRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final summary = ref.watch(homeStreakSummaryProvider);
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _StreakCard(
            value: '${summary.journalStreak}',
            label: l10n.homeStreakJournalLabel,
            color: glass.writeAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StreakCard(
            value: l10n.homeHabitsProgress(
              summary.habitsDone,
              summary.habitsTotal,
            ),
            label: l10n.homeStreakHabitsLabel,
            color: glass.habitAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StreakCard(
            value: '${summary.tasksDue}',
            label: l10n.homeStreakTasksLabel,
            color: glass.taskAccent,
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: glass.textMuted)),
        ],
      ),
    );
  }
}
