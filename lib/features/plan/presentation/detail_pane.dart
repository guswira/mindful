import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/detail_selection.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../habits/presentation/habit_detail_view.dart';
import '../../tasks/presentation/task_detail_sheet.dart';

/// The selected task's or routine's details beside the list in
/// `ListDetailLayout`, or a hint to pick one. Stays open after "Mark as
/// done" / logging (the item just moves); a deleted or converted item
/// falls back to the hint.
class DetailPane extends StatelessWidget {
  const DetailPane({
    required this.selection,
    required this.onCleared,
    super.key,
  });

  final DetailSelection? selection;

  /// The item was deleted from within the pane.
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: GlassCard(strong: true, child: _buildContent(context))),
      ],
    );
  }

  Widget _buildContent(BuildContext context) => switch (selection) {
    null => const _PickAnItemHint(),
    TaskDetailSelection(:final id) => TaskDetailView(
      key: ValueKey(selection),
      taskId: id,
      onFollowUp: (result) => showTaskFollowUp(context, result),
      onCompleted: () {},
      onDeleted: onCleared,
      notFound: const _PickAnItemHint(),
    ),
    RoutineDetailSelection(:final id) => HabitDetailView(
      key: ValueKey(selection),
      habitId: id,
      notFound: const _PickAnItemHint(),
    ),
  };
}

class _PickAnItemHint extends StatelessWidget {
  const _PickAnItemHint();

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rounded, size: 32, color: glass.taskAccent),
          const SizedBox(height: Spacing.sm),
          Text(
            context.l10n.detailSelectHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: glass.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
