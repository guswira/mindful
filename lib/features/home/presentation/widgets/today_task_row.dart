import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/task_complete_checkbox.dart';
import '../../../tasks/presentation/task_detail_sheet.dart';
import '../../../tasks/presentation/task_due_date_chip.dart';
import '../../../tasks/presentation/task_tab.dart';

/// Width of the leading slot (task checkbox / routine icon) in the Today's
/// Todo rows — shared so checkboxes, icons and names all line up in one
/// column. 40 = a shrink-wrapped [Checkbox].
const double todayRowLeadingWidth = 40;

/// Gap between the leading slot and the row's name.
const double todayRowLeadingGap = 8;

/// A due-today-or-overdue task: checkbox (completes it), name, due chip.
/// Tap opens [showTaskDetailSheet].
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => showTaskDetailSheet(context, task.id),
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
