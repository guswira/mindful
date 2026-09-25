import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/habit_action.dart';
import 'habit_form.dart' show generateHabitFormId;

/// Inline-editable custom action rows shown under "Custom actions" in
/// [AddHabitSheet] — each action is its own text field, added and removed
/// directly in place. Leaving the list empty gives the habit a single
/// "Done" button, per SPEC.md Habit Tracker.
class HabitActionsInlineEditor extends StatefulWidget {
  const HabitActionsInlineEditor({
    required this.actions,
    required this.onChanged,
    super.key,
  });

  final List<HabitAction> actions;
  final ValueChanged<List<HabitAction>> onChanged;

  @override
  State<HabitActionsInlineEditor> createState() =>
      _HabitActionsInlineEditorState();
}

class _HabitActionsInlineEditorState extends State<HabitActionsInlineEditor> {
  final _controllers = <String, TextEditingController>{};

  TextEditingController _controllerFor(HabitAction action) => _controllers
      .putIfAbsent(action.id, () => TextEditingController(text: action.label));

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _add() {
    widget.onChanged([
      ...widget.actions,
      HabitAction(id: generateHabitFormId(), label: ''),
    ]);
  }

  void _remove(HabitAction action) {
    _controllers.remove(action.id)?.dispose();
    widget.onChanged([
      for (final existing in widget.actions)
        if (existing.id != action.id) existing,
    ]);
  }

  void _relabel(HabitAction action, String label) {
    widget.onChanged([
      for (final existing in widget.actions)
        if (existing.id == action.id)
          existing.copyWith(label: label)
        else
          existing,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final action in widget.actions)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _ActionRow(
              controller: _controllerFor(action),
              onChanged: (label) => _relabel(action, label),
              onRemove: () => _remove(action),
            ),
          ),
        TextButton(
          onPressed: _add,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            foregroundColor: glass.habitAccent,
          ),
          child: Text(context.l10n.habitAddAction),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.controller,
    required this.onChanged,
    required this.onRemove,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          visualDensity: VisualDensity.compact,
          onPressed: onRemove,
        ),
      ],
    );
  }
}
