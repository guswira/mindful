import 'package:flutter/material.dart';

/// A small pill-shaped button tinted with an accent color, used for
/// primary actions inside glass cards (e.g. "Add task", "Start").
///
/// Sizes to its label; given a tight width (e.g. a full-width
/// `SizedBox`) the label and [icon] stay centered.
class TintedPill extends StatelessWidget {
  const TintedPill({
    required this.label,
    required this.color,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  /// Optional leading icon, in [color].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
