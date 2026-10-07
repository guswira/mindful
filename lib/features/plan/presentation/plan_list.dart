import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../habits/presentation/habit_tab.dart';
import '../../habits/presentation/habit_tab_list.dart';
import '../../tasks/presentation/task_tab.dart';
import '../../tasks/presentation/task_tab_list.dart';

/// Today's routines, then the grouped task list — the scrolling body of
/// [PlanTab], on its own or beside the task detail pane.
class PlanList extends ConsumerWidget {
  const PlanList({required this.padding, super.key});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(habitTabControllerProvider);
    final tasks = ref.watch(taskTabControllerProvider);
    return ListView(
      padding: padding,
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
    );
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
