import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/task_checkbox.dart';

/// Inline-editable subtask rows shown under the "Add subtasks" toggle in
/// [AddTaskSheet] — each subtask is its own text field, added and removed
/// directly in place.
class SubtasksEditor extends StatefulWidget {
  const SubtasksEditor({
    required this.checkboxes,
    required this.onChanged,
    super.key,
  });

  final List<TaskCheckbox> checkboxes;
  final ValueChanged<List<TaskCheckbox>> onChanged;

  @override
  State<SubtasksEditor> createState() => _SubtasksEditorState();
}

class _SubtasksEditorState extends State<SubtasksEditor> {
  final _controllers = <String, TextEditingController>{};

  TextEditingController _controllerFor(TaskCheckbox checkbox) =>
      _controllers.putIfAbsent(
        checkbox.id,
        () => TextEditingController(text: checkbox.label),
      );

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _add() {
    widget.onChanged([
      ...widget.checkboxes,
      TaskCheckbox(id: const Uuid().v4(), label: ''),
    ]);
  }

  void _remove(TaskCheckbox checkbox) {
    _controllers.remove(checkbox.id)?.dispose();
    widget.onChanged([
      for (final existing in widget.checkboxes)
        if (existing.id != checkbox.id) existing,
    ]);
  }

  void _relabel(TaskCheckbox checkbox, String label) {
    widget.onChanged([
      for (final existing in widget.checkboxes)
        if (existing.id == checkbox.id)
          existing.copyWith(label: label)
        else
          existing,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.sm),
        for (final checkbox in widget.checkboxes)
          _SubtaskRow(
            controller: _controllerFor(checkbox),
            onChanged: (label) => _relabel(checkbox, label),
            onRemove: () => _remove(checkbox),
          ),
        TextButton(
          onPressed: _add,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            foregroundColor: Theme.of(
              context,
            ).extension<GlassTheme>()!.taskAccent,
          ),
          child: Text(context.l10n.taskAddSubtask),
        ),
      ],
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
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
        const Icon(Icons.circle_outlined, color: Colors.white30, size: 16),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            decoration: InputDecoration(
              hintText: context.l10n.taskSubtaskHint,
              border: InputBorder.none,
              isDense: true,
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
