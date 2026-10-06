import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/journal_entry.dart';
import 'journal_labels.dart';

/// One chip per [JournalType]; the selected one is tinted journalAccent.
/// Always has a selection — there's no "untyped" entry.
class JournalTypeSelector extends StatelessWidget {
  const JournalTypeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final JournalType selected;
  final ValueChanged<JournalType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final type in JournalType.values)
          _TypeChip(
            type: type,
            isSelected: type == selected,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final JournalType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final accent = glass.journalAccent;
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.5)
                  : glass.cardBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                journalTypeIcon(type),
                size: 16,
                color: isSelected ? accent : glass.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.journalTypeName(type),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? accent : glass.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
