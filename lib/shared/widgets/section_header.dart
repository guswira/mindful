import 'package:flutter/material.dart';

import '../../core/theme/glass_theme.dart';

/// Section title with a small muted text action on the right ("view all",
/// "History", ...), or just the title when there's no action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.titleColor = Colors.white,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          if (actionLabel case final label?)
            Semantics(
              button: onAction != null,
              child: GestureDetector(
                onTap: onAction,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: glass.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
