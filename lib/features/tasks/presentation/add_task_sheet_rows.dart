import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/shake_widget.dart';

/// The task name field inside [AddTaskSheet], shaking via [shakeKey] when
/// saved empty.
class TaskNameField extends StatelessWidget {
  const TaskNameField({
    required this.shakeKey,
    required this.controller,
    super.key,
  });

  final GlobalKey<ShakeWidgetState> shakeKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return ShakeWidget(
      key: shakeKey,
      child: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: glass.taskAccent,
        textInputAction: TextInputAction.done,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: context.l10n.taskNameHint,
          hintStyle: TextStyle(color: glass.textHint),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

/// A tappable row for an optional field inside [AddTaskSheet]: an icon and
/// label, or — once [value] is set — the chosen value with a clear button.
/// Shared by the due-date and reminder rows.
class SheetOptionRow extends StatelessWidget {
  const SheetOptionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            children: [
              Icon(icon, color: glass.textMuted, size: 18),
              const SizedBox(width: Spacing.sm),
              Text(
                label,
                style: TextStyle(color: glass.textMuted, fontSize: 14),
              ),
              const Spacer(),
              if (value case final value?) ...[
                Text(
                  value,
                  style: TextStyle(
                    color: glass.taskAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                  onPressed: onClear,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Add subtasks" toggle row inside [AddTaskSheet].
class SubtasksToggleRow extends StatelessWidget {
  const SubtasksToggleRow({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(Icons.checklist, color: glass.textMuted, size: 18),
          const SizedBox(width: Spacing.sm),
          Text(
            context.l10n.taskAddSubtasks,
            style: TextStyle(color: glass.textMuted, fontSize: 14),
          ),
          const Spacer(),
          Switch(
            value: value,
            activeThumbColor: glass.taskAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
