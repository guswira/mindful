import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../domain/entry_visibility.dart';

/// The "Who sees it" chips on [AddMoneySheet] while linked — Shared with
/// the partner / Private — plus a line on what the pick means. See SPEC.md
/// Money Flow Feature Linked partner.
class VisibilityPicker extends StatelessWidget {
  const VisibilityPicker({
    required this.selected,
    required this.partnerName,
    required this.onChanged,
    super.key,
  });

  final EntryVisibility selected;

  /// The partner's first name, for the Shared chip and hint.
  final String partnerName;
  final ValueChanged<EntryVisibility> onChanged;

  String _label(AppLocalizations l10n, EntryVisibility visibility) =>
      switch (visibility) {
        EntryVisibility.shared => l10n.moneyVisibilityShared(partnerName),
        EntryVisibility.private => l10n.moneyVisibilityPrivate,
      };

  String _hint(AppLocalizations l10n) => switch (selected) {
    EntryVisibility.shared => l10n.moneyVisibilitySharedHint(partnerName),
    EntryVisibility.private => l10n.moneyVisibilityPrivateHint,
  };

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.moneyVisibilityHeading,
          style: TextStyle(color: glass.textHint, fontSize: 12),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final visibility in EntryVisibility.values)
              _VisibilityChip(
                icon: visibilityIcon(visibility),
                label: _label(l10n, visibility),
                active: visibility == selected,
                onTap: () => onChanged(visibility),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          _hint(l10n),
          style: TextStyle(color: glass.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// people_outline for shared, lock_outline for private.
IconData visibilityIcon(EntryVisibility visibility) => switch (visibility) {
  EntryVisibility.shared => Icons.people_outline,
  EntryVisibility.private => Icons.lock_outline,
};

class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final color = glass.moneySpending;
    final textColor = active ? Colors.white : glass.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : glass.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.25) : glass.cardBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: Spacing.xs),
            Text(label, style: TextStyle(color: textColor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
