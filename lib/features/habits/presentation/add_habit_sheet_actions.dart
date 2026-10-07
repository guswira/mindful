import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/habit_action.dart';
import '../domain/habit_tag.dart';
import 'habit_form.dart' show generateHabitFormId;

/// Inline-editable custom action rows shown under "Custom actions" in
/// [AddHabitSheet] — each action is its own text field, added and removed
/// directly in place. Leaving the list empty gives the habit a single
/// "Done" button, per SPEC.md Habit Tracker.
class HabitActionsInlineEditor extends StatelessWidget {
  const HabitActionsInlineEditor({
    required this.actions,
    required this.onChanged,
    super.key,
  });

  final List<HabitAction> actions;
  final ValueChanged<List<HabitAction>> onChanged;

  @override
  Widget build(BuildContext context) {
    return _LabelListEditor<HabitAction>(
      items: actions,
      onChanged: onChanged,
      idOf: (action) => action.id,
      labelOf: (action) => action.label,
      relabel: (action, label) => action.copyWith(label: label),
      create: () => HabitAction(id: generateHabitFormId(), label: ''),
      addLabel: context.l10n.habitAddAction,
    );
  }
}

/// Inline-editable tag rows shown under "Tags" in [AddHabitSheet], edited
/// the same way as [HabitActionsInlineEditor]. Tags are optional and apply
/// to every action — see SPEC.md Tasks & Routines.
class HabitTagsInlineEditor extends StatelessWidget {
  const HabitTagsInlineEditor({
    required this.tags,
    required this.onChanged,
    super.key,
  });

  final List<HabitTag> tags;
  final ValueChanged<List<HabitTag>> onChanged;

  @override
  Widget build(BuildContext context) {
    return _LabelListEditor<HabitTag>(
      items: tags,
      onChanged: onChanged,
      idOf: (tag) => tag.id,
      labelOf: (tag) => tag.label,
      relabel: (tag, label) => tag.copyWith(label: label),
      create: () => HabitTag(id: generateHabitFormId(), label: ''),
      addLabel: context.l10n.habitAddTag,
    );
  }
}

class _LabelListEditor<T> extends StatefulWidget {
  const _LabelListEditor({
    required this.items,
    required this.onChanged,
    required this.idOf,
    required this.labelOf,
    required this.relabel,
    required this.create,
    required this.addLabel,
  });

  final List<T> items;
  final ValueChanged<List<T>> onChanged;
  final String Function(T item) idOf;
  final String Function(T item) labelOf;
  final T Function(T item, String label) relabel;
  final T Function() create;
  final String addLabel;

  @override
  State<_LabelListEditor<T>> createState() => _LabelListEditorState<T>();
}

class _LabelListEditorState<T> extends State<_LabelListEditor<T>> {
  final _controllers = <String, TextEditingController>{};

  TextEditingController _controllerFor(T item) => _controllers.putIfAbsent(
    widget.idOf(item),
    () => TextEditingController(text: widget.labelOf(item)),
  );

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _add() => widget.onChanged([...widget.items, widget.create()]);

  void _remove(T item) {
    final id = widget.idOf(item);
    _controllers.remove(id)?.dispose();
    widget.onChanged([
      for (final existing in widget.items)
        if (widget.idOf(existing) != id) existing,
    ]);
  }

  void _relabel(T item, String label) {
    final id = widget.idOf(item);
    widget.onChanged([
      for (final existing in widget.items)
        if (widget.idOf(existing) == id)
          widget.relabel(existing, label)
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
        for (final item in widget.items)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _ActionRow(
              controller: _controllerFor(item),
              onChanged: (label) => _relabel(item, label),
              onRemove: () => _remove(item),
            ),
          ),
        TextButton(
          onPressed: _add,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            foregroundColor: glass.habitAccent,
          ),
          child: Text(widget.addLabel),
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
