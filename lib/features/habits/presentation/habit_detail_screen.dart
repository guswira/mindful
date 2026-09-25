import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_log.dart';
import 'add_habit_sheet.dart';
import 'habit_calendar.dart';
import 'habit_form.dart';
import 'habit_providers.dart';

part 'habit_detail_screen.g.dart';

/// The calendar month currently shown, and every completion log loaded so
/// far (accumulated as the user swipes between months).
typedef HabitDetailState = ({
  DateTime month,
  Map<DateTime, HabitLog> logsByDate,
});

/// Loads a habit's completion logs a month at a time, starting with the
/// current and previous month so streaks have a sensible default window.
@riverpod
class HabitDetailController extends _$HabitDetailController {
  @override
  Future<HabitDetailState> build(String habitId) async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    final logs = await _fetchMonth(month);
    final previousLogs = await _fetchMonth(previousMonth);
    return (month: month, logsByDate: {...previousLogs, ...logs});
  }

  /// Moves the displayed month by [delta] (±1), fetching it if it isn't
  /// already loaded.
  Future<void> changeMonth(int delta) async {
    final current = await future;
    final newMonth = DateTime(current.month.year, current.month.month + delta);
    final newLogs = await _fetchMonth(newMonth);
    state = AsyncData((
      month: newMonth,
      logsByDate: {...current.logsByDate, ...newLogs},
    ));
  }

  Future<Map<DateTime, HabitLog>> _fetchMonth(DateTime month) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final logs = await repository.logsForHabitInMonth(habitId, month);
    return {for (final log in logs) _dateOnly(log.date): log};
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// A habit's current and longest streak, computed over whichever months are
/// loaded — not necessarily the habit's entire history. See
/// [HabitDetailController].
({int current, int longest}) _computeStreaks(
  Map<DateTime, HabitLog> logsByDate,
) {
  if (logsByDate.isEmpty) {
    return (current: 0, longest: 0);
  }
  final days = logsByDate.keys.toList()..sort();

  var longest = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    run = days[i].difference(days[i - 1]).inDays == 1 ? run + 1 : 1;
    if (run > longest) {
      longest = run;
    }
  }

  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);
  if (!logsByDate.containsKey(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var current = 0;
  while (logsByDate.containsKey(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return (current: current, longest: longest);
}

/// Monthly calendar of a habit's completions, with streaks and a
/// swipe-to-change-month gesture.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(id));
    final detailAsync = ref.watch(habitDetailControllerProvider(id));

    final habit = habitAsync.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(habit?.name ?? context.l10n.habitFallbackTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: habit == null
                ? null
                : () => showGlassBottomSheet(
                    context: context,
                    builder: (_) => AddHabitSheet(habit: habit),
                  ),
          ),
        ],
      ),
      body: switch ((habitAsync, detailAsync)) {
        (AsyncData(value: final habit?), AsyncData(:final value)) =>
          _HabitDetailBody(habit: habit, state: value),
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          Center(child: Text(context.l10n.habitLoadError('$error'))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _HabitDetailBody extends ConsumerWidget {
  const _HabitDetailBody({required this.habit, required this.state});

  final Habit habit;
  final HabitDetailState state;

  Future<void> _changeMonth(WidgetRef ref, int delta) async {
    await ref
        .read(habitDetailControllerProvider(habit.id).notifier)
        .changeMonth(delta);
  }

  void _showLogDetails(BuildContext context, HabitLog log) {
    final actionLabel = switch (log.completedActionId) {
      null => context.l10n.commonDone,
      final actionId =>
        habit.actions
            .where((action) => action.id == actionId)
            .map((action) => action.label)
            .firstOrElse(actionId),
    };
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat.yMMMd().format(log.date)),
        content: Text(
          log.note == null ? actionLabel : '$actionLabel\n${log.note}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.commonClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = _computeStreaks(state.logsByDate);
    final habitAccent = Theme.of(context).extension<GlassTheme>()!.habitAccent;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _changeMonth(ref, 1);
        } else if (velocity > 0) {
          _changeMonth(ref, -1);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          HabitStreakRow(current: streaks.current, longest: streaks.longest),
          const SizedBox(height: Spacing.md),
          HabitMonthHeader(
            month: state.month,
            onPrevious: () => _changeMonth(ref, -1),
            onNext: () => _changeMonth(ref, 1),
          ),
          const SizedBox(height: Spacing.sm),
          HabitMonthGrid(
            month: state.month,
            color: parseHexColorOr(habit.color, habitAccent),
            logsByDate: state.logsByDate,
            onDayTap: (log) => _showLogDetails(context, log),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T firstOrElse(T fallback) => isEmpty ? fallback : first;
}
