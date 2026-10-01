import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/blob_background.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/glass_icon_button.dart';
import '../../habits/presentation/add_habit_sheet.dart';
import '../../habits/presentation/habit_tab.dart';
import '../../habits/presentation/habit_tab_list.dart';
import '../../tasks/presentation/add_task_sheet.dart';
import '../../tasks/presentation/task_tab.dart';
import '../../tasks/presentation/task_tab_list.dart';

/// Tasks and routines (habits) on one page: today's routines first, since
/// they repeat every day, then the grouped task list. Home and the home
/// screen widgets still show them separately. See SPEC.md Tasks & Routines.
class PlanTab extends ConsumerWidget {
  const PlanTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(habitTabControllerProvider);
    final tasks = ref.watch(taskTabControllerProvider);

    return Scaffold(
      body: RepaintBoundary(
        child: BlobBackground(
          child: SafeArea(
            child: Column(
              children: [
                const _PlanHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
                    children: [
                      _AsyncSection(
                        value: routines,
                        errorText: context.l10n.habitLoadListError,
                        builder: (items) => RoutineSection(items: items),
                      ),
                      const SizedBox(height: Spacing.lg),
                      _AsyncSection(
                        value: tasks,
                        errorText: context.l10n.taskLoadListError,
                        builder: (tasks) => TaskSections(tasks: tasks),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.planTabTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GlassIconButton(
            icon: Icons.add,
            tooltip: context.l10n.planAdd,
            onTap: () => _showAddOptions(context),
          ),
        ],
      ),
    );
  }

  /// "Add task" / "Add habit" — the one "+" covers both halves of the tab.
  void _showAddOptions(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    showGlassBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.checklist_outlined, color: glass.taskAccent),
            title: Text(l10n.taskAddTask),
            onTap: () => _open(sheetContext, context, const AddTaskSheet()),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_month_outlined,
              color: glass.habitAccent,
            ),
            title: Text(l10n.habitAddHabit),
            onTap: () => _open(sheetContext, context, const AddHabitSheet()),
          ),
        ],
      ),
    );
  }

  /// Closes the options sheet, then opens [sheet] over [context] (the
  /// options sheet's own context is gone once it's popped).
  void _open(BuildContext sheetContext, BuildContext context, Widget sheet) {
    Navigator.pop(sheetContext);
    showGlassBottomSheet<void>(context: context, builder: (_) => sheet);
  }
}

/// [builder]'s section once [value] has loaded; a spinner or [errorText]
/// otherwise, so one half failing doesn't hide the other.
class _AsyncSection<T> extends StatelessWidget {
  const _AsyncSection({
    required this.value,
    required this.errorText,
    required this.builder,
  });

  final AsyncValue<T> value;
  final String Function(String error) errorText;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => Text(
        errorText('$error'),
        style: TextStyle(
          color: Theme.of(context).extension<GlassTheme>()!.textSecondary,
        ),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
