import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/journal_entry.dart';

/// Sticky mood picker: 5 emoji buttons, the selected one scaled up with a
/// journalAccent underline dot. See SPEC.md Journal Editor Screen.
class JournalMoodBar extends StatelessWidget {
  const JournalMoodBar({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Mood? selected;
  final ValueChanged<Mood?> onChanged;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final mood in Mood.values)
            _MoodButton(
              mood: mood,
              isSelected: selected == mood,
              activeColor: glass.journalAccent,
              onTap: () => onChanged(selected == mood ? null : mood),
            ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final Mood mood;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Opacity(
          opacity: isSelected ? 1 : 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky bottom row: photo picker (with a count badge) on the left, Save
/// on the right. See SPEC.md Journal Editor Screen.
class JournalActionBar extends StatelessWidget {
  const JournalActionBar({
    required this.photoCount,
    required this.saving,
    required this.onPickPhoto,
    required this.onSave,
    super.key,
  });

  final int photoCount;
  final bool saving;
  final VoidCallback onPickPhoto;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPickPhoto,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white60,
                  size: 22,
                ),
                if (photoCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$photoCount',
                    style: TextStyle(fontSize: 12, color: glass.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          if (saving)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: glass.journalAccent,
                strokeWidth: 2,
              ),
            )
          else
            TintedPill(
              label: context.l10n.commonSave,
              color: glass.journalAccent,
              onTap: onSave,
            ),
        ],
      ),
    );
  }
}
