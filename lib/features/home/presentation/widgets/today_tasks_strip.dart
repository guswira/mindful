import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/dashed_border_container.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/add_task_sheet.dart';
import '../../../tasks/presentation/task_complete_checkbox.dart';
import '../../../tasks/presentation/task_detail_sheet.dart';
import '../../../tasks/presentation/task_due_date_chip.dart';
import '../../../tasks/presentation/task_tab.dart';

const int _maxRowsShown = 3;

void _openAddTaskSheet(BuildContext context) => showGlassBottomSheet(
  context: context,
  builder: (_) => const AddTaskSheet(),
);

/// Today's tasks glass card: up to 3 due-today-or-overdue tasks, a dashed
/// empty state, and an always-visible add row. See SPEC.md Home Screen.
class TodayTasksStrip extends ConsumerWidget {
  const TodayTasksStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskTabControllerProvider);

    return switch (tasksAsync) {
      AsyncData(:final value) => _TaskCard(tasks: _dueTodayOrOverdue(value)),
      AsyncError() => const SizedBox.shrink(),
      _ => const SizedBox(
        height: 96,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }

  static List<Task> _dueTodayOrOverdue(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (final task in tasks)
        if (!task.isCompleted &&
            task.dueDate != null &&
            !_dateOnly(task.dueDate!).isAfter(today))
          task,
    ];
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tasks.isEmpty)
            DashedBorderContainer(
              color: Colors.white.withValues(alpha: 0.15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.homeTasksEmpty,
                  style: TextStyle(fontSize: 14, color: glass.textHint),
                ),
              ),
            )
          else ...[
            for (final task in tasks.take(_maxRowsShown)) _TaskRow(task: task),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openAddTaskSheet(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: glass.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: glass.cardBorder, width: 0.5),
                  ),
                  child: const Icon(Icons.add, color: Colors.white70, size: 18),
                ),
              ),
              const Spacer(),
              TintedPill(
                label: context.l10n.homeAddTask,
                color: glass.taskAccent,
                onTap: () => _openAddTaskSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});

  final Task task;

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskTabControllerProvider.notifier).complete(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.homeSyncFailed(task.name, '$error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showGlassBottomSheet(
          context: context,
          builder: (_) => TaskDetailSheet(taskId: task.id),
        ),
        child: Row(
          children: [
            TaskCompleteCheckbox(
              value: false,
              onChanged: (_) => _complete(context, ref),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            if (task.dueDate != null) TaskDueDateChip(dueDate: task.dueDate!),
          ],
        ),
      ),
    );
  }
}
