import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';

/// A persistent bottom bar holding a screen's one primary action — Add,
/// Save, Confirm or Done — per `.claude/rules/ui.md`'s UI conventions:
/// primary actions never live in the app bar or float mid-screen.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.label,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(Spacing.md),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
