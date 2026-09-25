import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/task_checkbox.dart';

/// A single icon + label row in [TaskDetailSheet], e.g. its due date or
/// reminder time.
class TaskDetailRow extends StatelessWidget {
  const TaskDetailRow({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(width: Spacing.sm),
          Text(
            text,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// The subtasks section of [TaskDetailSheet]: a progress bar plus a
/// checkable row per subtask.
class TaskChecklist extends StatelessWidget {
  const TaskChecklist({
    required this.checkboxes,
    required this.onToggle,
    super.key,
  });

  final List<TaskCheckbox> checkboxes;
  final ValueChanged<TaskCheckbox> onToggle;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final total = checkboxes.length;
    final done = checkboxes.where((checkbox) => checkbox.isChecked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.taskSubtasks,
          style: TextStyle(color: glass.textMuted, fontSize: 13),
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            color: glass.taskAccent,
            backgroundColor: Colors.white10,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        for (final checkbox in checkboxes)
          _ChecklistRow(checkbox: checkbox, onTap: () => onToggle(checkbox)),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.checkbox, required this.onTap});

  final TaskCheckbox checkbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final checked = checkbox.isChecked;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: checked
                    ? Theme.of(context).extension<GlassTheme>()!.taskAccent
                    : Colors.transparent,
                border: checked ? null : Border.all(color: Colors.white30),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: checked ? 0.4 : 0.8),
                  decoration: checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                child: Text(checkbox.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
