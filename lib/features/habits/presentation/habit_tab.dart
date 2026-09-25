import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/services/widget_service.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_icon_button.dart';
import '../../auth/domain/auth_state.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';
import '../domain/habit_action.dart';
import '../domain/habit_log.dart';
import 'add_habit_sheet.dart';
import 'habit_tab_list.dart';

part 'habit_tab.g.dart';

/// A habit plus its completion log for today, if any.
typedef HabitTabItem = ({Habit habit, HabitLog? todayLog});

/// Loads today's active habits and their completion status, and logs new
/// completions to the cache (then Supabase, best-effort).
@riverpod
class HabitTabController extends _$HabitTabController {
  @override
  Future<List<HabitTabItem>> build() async {
    final repository = await ref.watch(habitRepositoryProvider.future);
    unawaited(_refreshFromSupabase(repository));
    return _loadToday(repository);
  }

  Future<void> _refreshFromSupabase(HabitRepository repository) async {
    try {
      await repository.refreshFromSupabase();
      ref.invalidateSelf();
    } catch (_) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
    }
  }

  List<HabitTabItem> _loadToday(HabitRepository repository) {
    final today = DateTime.now();
    return [
      for (final habit in repository.getHabits())
        if (!habit.archived)
          (habit: habit, todayLog: repository.getLog(habit.id, today)),
    ];
  }

  /// Logs [habit] as completed via [action] (or plain "done" if null) for
  /// today. Reuses today's existing log id, if any, instead of minting a
  /// new one on every toggle.
  Future<void> logAction(Habit habit, HabitAction? action) async {
    final repository = await ref.read(habitRepositoryProvider.future);
    final userId = ref.read(currentUserIdProvider);
    final today = DateTime.now();
    final existing = repository.getLog(habit.id, today);
    await repository.saveLog(
      HabitLog(
        id: existing?.id ?? const Uuid().v4(),
        userId: userId,
        habitId: habit.id,
        date: today,
        completedActionId: action?.id,
      ),
    );
    ref.invalidateSelf();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }
}

/// Today's active habits, each with its action buttons highlighted once
/// logged for the day. See SPEC.md Habit Tracker.
class HabitTab extends ConsumerWidget {
  const HabitTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final items = ref.watch(habitTabControllerProvider);

    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.habitTabTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GlassIconButton(
                        icon: Icons.add,
                        tooltip: context.l10n.habitAddHabit,
                        onTap: () => showGlassBottomSheet(
                          context: context,
                          builder: (_) => const AddHabitSheet(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (items) {
                    AsyncData(:final value) => HabitList(items: value),
                    AsyncError(:final error) => Center(
                      child: Text(
                        context.l10n.habitLoadListError('$error'),
                        style: TextStyle(color: glass.textSecondary),
                      ),
                    ),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
