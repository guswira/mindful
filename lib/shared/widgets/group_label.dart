import 'package:flutter/material.dart';

import '../../core/theme/glass_theme.dart';

/// Small muted heading above a glass card of list rows — e.g. a task group
/// or the routines section on the Tasks & Routines tab.
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: glass.textMuted,
      ),
    );
  }
}
