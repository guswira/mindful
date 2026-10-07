import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_page_scaffold.dart';
import '../../auth/domain/auth_state.dart';
import '../data/habit_repository.dart';
import '../domain/habit_log.dart';
import 'add_habit_sheet.dart';
import 'habit_day_log_sheet.dart';
import 'habit_providers.dart';
import 'habit_detail_body.dart';
import 'habit_tab.dart';

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

  /// Rewrites the log on [date] to [choice] — saved (keeping the day's log
  /// id and note; [tags] replaces its tag counts when given) or deleted —
  /// and updates the loaded logs in place. Also
  /// refreshes today's routine list and the home widgets, since [date] may
  /// be today. A failed Supabase delete is rethrown for the caller to
  /// surface, after the cache and [state] have already dropped the log.
  Future<void> setDayLog(
    DateTime date,
    HabitDayChoice choice, {
    Map<String, int>? tags,
  }) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final current = await future;
    final day = _dateOnly(date);
    final logs = {...current.logsByDate};
    final existing = logs[day] ?? repository.getLog(habitId, day);
    try {
      if (choice.done) {
        final log = HabitLog(
          id: existing?.id ?? const Uuid().v4(),
          userId: ref.read(currentUserIdProvider),
          habitId: habitId,
          date: day,
          completedActionId: choice.actionId,
          note: existing?.note,
          tags: tags ?? existing?.tags,
        );
        logs[day] = log;
        await repository.saveLog(log);
      } else {
        logs.remove(day);
        await repository.deleteLog(habitId, day);
      }
    } finally {
      state = AsyncData((month: current.month, logsByDate: logs));
      ref.invalidate(habitTabControllerProvider);
      await refreshWidgetsBestEffort(
        () => ref.read(widgetServiceProvider.future),
      );
    }
  }

  Future<Map<DateTime, HabitLog>> _fetchMonth(DateTime month) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final logs = await repository.logsForHabitInMonth(habitId, month);
    return {for (final log in logs) _dateOnly(log.date): log};
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
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
    return GlassPageScaffold(
      title: Text(habit?.name ?? context.l10n.habitFallbackTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white70),
          onPressed: habit == null
              ? null
              : () => showGlassBottomSheet(
                  context: context,
                  builder: (_) => AddHabitSheet(habit: habit),
                ),
        ),
      ],
      body: switch ((habitAsync, detailAsync)) {
        (AsyncData(value: final habit?), AsyncData(:final value)) =>
          HabitDetailBody(habit: habit, state: value),
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          Center(child: Text(context.l10n.habitLoadError('$error'))),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
