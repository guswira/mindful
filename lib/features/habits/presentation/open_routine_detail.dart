import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/detail_selection.dart';

/// Shows [habitId]'s calendar in the detail pane when there is one on
/// screen, else pushes `HabitDetailScreen` (/habits/:id).
void openRoutineDetail(BuildContext context, String habitId) {
  if (!DetailSelectionScope.trySelect(
    context,
    RoutineDetailSelection(habitId),
  )) {
    context.push('/habits/$habitId');
  }
}
