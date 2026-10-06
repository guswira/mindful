import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/tinted_pill.dart';
import '../domain/journal_entry.dart';
import 'add_journal_sheet.dart';

/// "Write today's plan" and "Review today" rows, each opening the quick
/// journal sheet on the matching [JournalType]. Meant to sit inside a
/// GlassCard — shared by home's Mindfulness card and the Mindfulness tab's
/// empty "today" state.
class JournalPromptRows extends StatelessWidget {
  const JournalPromptRows({super.key});

  void _openAddJournalSheet(BuildContext context, JournalType type) =>
      showGlassBottomSheet(
        context: context,
        builder: (_) => AddJournalSheet(initialType: type),
      );

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return Column(
      children: [
        PromptRow(
          icon: Icons.edit_note_rounded,
          iconColor: glass.journalAccent,
          title: l10n.homeJournalPlanTitle,
          subtitle: l10n.homeJournalPlanSubtitle,
          pillLabel: l10n.homeJournalPlanAction,
          pillColor: glass.journalAccent,
          onTap: () => _openAddJournalSheet(context, JournalType.plan),
        ),
        const PromptRowDivider(),
        PromptRow(
          icon: Icons.nightlight_outlined,
          iconColor: glass.habitAccent,
          title: l10n.homeJournalReflectTitle,
          subtitle: l10n.homeJournalReflectSubtitle,
          pillLabel: l10n.homeJournalReflectAction,
          pillColor: glass.taskAccent,
          onTap: () => _openAddJournalSheet(context, JournalType.review),
        ),
      ],
    );
  }
}

/// 0.5px white7 divider between [PromptRow]s in one glass card.
class PromptRowDivider extends StatelessWidget {
  const PromptRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.07),
    );
  }
}

/// Glass-card row: flat icon in a tinted square, title + subtitle and a
/// [TintedPill]; the whole row and the pill both run [onTap].
class PromptRow extends StatelessWidget {
  const PromptRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillColor,
    required this.onTap,
    super.key,
  });

  /// Flat icon drawn in [iconColor] on a tinted square.
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String pillLabel;
  final Color pillColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: glass.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TintedPill(label: pillLabel, color: pillColor, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}
