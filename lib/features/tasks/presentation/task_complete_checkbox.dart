import 'package:flutter/material.dart';

/// A checkbox that plays a brief scale animation when checked, per
/// SPEC.md's UI conventions: "Task checkbox completion uses a satisfying
/// check animation." Unchecking isn't supported — passing null for
/// [onChanged] (e.g. for an already-completed task) disables it entirely.
class TaskCompleteCheckbox extends StatefulWidget {
  const TaskCompleteCheckbox({
    required this.value,
    required this.onChanged,
    this.activeColor,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  @override
  State<TaskCompleteCheckbox> createState() => _TaskCompleteCheckboxState();
}

class _TaskCompleteCheckboxState extends State<TaskCompleteCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(bool? checked) {
    final onChanged = widget.onChanged;
    if (checked != true || onChanged == null) {
      return;
    }
    _controller.forward(from: 0);
    onChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Checkbox(
        value: widget.value,
        activeColor: widget.activeColor,
        onChanged: _handleChanged,
      ),
    );
  }
}
