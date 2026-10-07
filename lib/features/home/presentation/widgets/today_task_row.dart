import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/detail_selection.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/task_complete_checkbox.dart';
import '../../../tasks/presentation/open_task_detail.dart';
import '../../../tasks/presentation/task_due_date_chip.dart';
import '../../../tasks/presentation/task_tab.dart';

/// Width of the leading slot (task checkbox / routine icon) in the Today's
/// Todo rows — shared so checkboxes, icons and names all line up in one
/// column. 40 = a shrink-wrapped [Checkbox].
const double todayRowLeadingWidth = 40;

/// Gap between the leading slot and the row's name.
const double todayRowLeadingGap = 8;

/// A due-today-or-overdue task: checkbox (completes it), name, due chip.
/// Tap opens its details ([openTaskDetail]: the pane beside Home on a
/// tablet / in landscape, else a sheet).
class TodayTaskRow extends ConsumerWidget {
  const TodayTaskRow({required this.task, super.key});

  final Task task;

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(taskTabControllerProvider.notifier).complete(task.id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.homeSyncFailed(task.name, '$error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    // Marks the task shown in the detail pane.
    final selected = DetailSelectionScope.isSelected(
      context,
      TaskDetailSelection(task.id),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => openTaskDetail(context, task.id),
        child: Row(
          children: [
            SizedBox(
              width: todayRowLeadingWidth,
              child: Center(
                child: TaskCompleteCheckbox(
                  value: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => _complete(context, ref),
                ),
              ),
            ),
            const SizedBox(width: todayRowLeadingGap),
            Expanded(
              child: Text(
                task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? glass.taskAccent : Colors.white,
                ),
              ),
            ),
            if (task.dueDate != null) TaskDueDateChip(dueDate: task.dueDate!),
          ],
        ),
      ),
    );
  }
}
