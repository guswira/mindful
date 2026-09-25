import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A small chip showing [dueDate], styled as overdue when it's before today.
class TaskDueDateChip extends StatelessWidget {
  const TaskDueDateChip({required this.dueDate, super.key});

  final DateTime dueDate;

  bool get _isOverdue {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return dueDate.isBefore(day);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final overdue = _isOverdue;
    return Chip(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      backgroundColor: overdue
          ? colors.errorContainer
          : colors.secondaryContainer,
      label: Text(
        DateFormat.MMMd().format(dueDate),
        style: TextStyle(
          color: overdue
              ? colors.onErrorContainer
              : colors.onSecondaryContainer,
        ),
      ),
    );
  }
}
