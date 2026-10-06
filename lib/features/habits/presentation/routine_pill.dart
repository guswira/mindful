import 'package:flutter/material.dart';

import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/tinted_pill.dart';

/// A routine action pill: tinted in the routine's [color] once [selected]
/// (logged today), plain glass with grey text until then.
class RoutinePill extends StatelessWidget {
  const RoutinePill({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return TintedPill(label: label, color: color, onTap: onTap);
    }
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: glass.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glass.cardBorder, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: glass.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
