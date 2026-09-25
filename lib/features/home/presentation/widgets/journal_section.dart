import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../../../journal/presentation/add_journal_sheet.dart';

/// Journal glass card: write today's plan and reflect on the day, both
/// opening the quick-entry bottom sheet. See SPEC.md Home Screen.
class JournalSection extends StatelessWidget {
  const JournalSection({super.key});

  void _openAddJournalSheet(BuildContext context) => showGlassBottomSheet(
    context: context,
    builder: (_) => const AddJournalSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _JournalRow(
            icon: '✏️',
            iconColor: glass.journalAccent,
            title: l10n.homeJournalPlanTitle,
            subtitle: l10n.homeJournalPlanSubtitle,
            pillLabel: l10n.homeJournalPlanAction,
            pillColor: glass.journalAccent,
            onTap: () => _openAddJournalSheet(context),
          ),
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.07),
          ),
          _JournalRow(
            icon: '📖',
            iconColor: glass.habitAccent,
            title: l10n.homeJournalReflectTitle,
            subtitle: l10n.homeJournalReflectSubtitle,
            pillLabel: l10n.homeJournalReflectAction,
            pillColor: glass.taskAccent,
            onTap: () => _openAddJournalSheet(context),
          ),
        ],
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.pillLabel,
    required this.pillColor,
    required this.onTap,
  });

  final String icon;
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
                child: Text(icon, style: const TextStyle(fontSize: 18)),
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
