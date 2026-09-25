import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import 'habit_form.dart' show parseHexColor;

/// Common habit emoji offered by [HabitIconGrid].
const List<String> habitSheetIconPresets = [
  '💪',
  '🏃',
  '📚',
  '🧘',
  '💧',
  '🥗',
  '😴',
  '🎯',
  '✍️',
  '🎵',
  '🌿',
  '🧹',
  '💊',
  '🛁',
  '🌅',
  '🏋️',
  '🚴',
  '🧠',
  '❤️',
  '⭐',
];

/// Preset colors offered by [HabitColorRow] — the four accent colors from
/// SPEC.md's design tokens plus three extras, all stored as the "#RRGGBB"
/// hex strings a [Habit] persists.
const List<String> habitSheetColorPresets = [
  '#14E6AA', // accent teal
  '#7C6AF7', // accent purple
  '#F7C46A', // accent amber
  '#6BB8F0', // accent blue
  '#FF6B6B',
  '#98D8C8',
  '#FFB347',
];

/// Grid of emoji swatches for picking a habit's icon, per the bottom-sheet
/// design rules.
class HabitIconGrid extends StatelessWidget {
  const HabitIconGrid({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final emoji in habitSheetIconPresets)
          _IconSwatch(
            emoji: emoji,
            selected: emoji == selected,
            onTap: () => onChanged(emoji),
          ),
      ],
    );
  }
}

class _IconSwatch extends StatelessWidget {
  const _IconSwatch({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final swatch = GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          selected
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: glass.habitAccent, width: 1.5),
                  ),
                  child: swatch,
                )
              : swatch,
          if (selected)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glass.habitAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Row of color swatches for picking a habit's color, per the bottom-sheet
/// design rules.
class HabitColorRow extends StatelessWidget {
  const HabitColorRow({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final hex in habitSheetColorPresets)
          _ColorSwatch(
            hex: hex,
            selected: hex == selected,
            onTap: () => onChanged(hex),
          ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: parseHexColor(hex),
            border: selected ? Border.all(color: Colors.white, width: 2) : null,
          ),
        ),
      ),
    );
  }
}
