import 'package:flutter/widgets.dart';

import '../../../shared/widgets/detail_selection.dart';
import 'task_detail_sheet.dart';

/// Shows [taskId] in the detail pane when there is one on screen, else in
/// [showTaskDetailSheet].
void openTaskDetail(BuildContext context, String taskId) {
  if (!DetailSelectionScope.trySelect(context, TaskDetailSelection(taskId))) {
    showTaskDetailSheet(context, taskId);
  }
}
