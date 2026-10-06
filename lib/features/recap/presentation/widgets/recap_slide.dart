import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tinted_pill.dart';
import '../recap_slide_data.dart';
import 'recap_hero.dart';

/// One full-screen page of the monthly recap: section badge, hero number,
/// stat chips and the motivation line it always ends on.
class RecapSlide extends StatelessWidget {
  const RecapSlide({required this.data, this.onDone, super.key});

  final RecapSlideData data;

  /// Shown as a "Done" pill when [RecapSlideData.isLast].
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SectionBadge(data: data),
          const SizedBox(height: Spacing.lg),
          RecapHero(data: data),
          if (data.stats.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            _StatWrap(data: data),
          ],
          const SizedBox(height: Spacing.lg),
          _MotivationCard(data: data),
          if (data.isLast) ...[
            const SizedBox(height: Spacing.lg),
            TintedPill(
              label: context.l10n.recapDone,
              color: data.accent,
              onTap: onDone,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.data});

  final RecapSlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: data.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: data.accent.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Icon(data.icon, size: 34, color: data.accent),
        ),
        const SizedBox(height: Spacing.md - 4),
        Text(
          data.title.toUpperCase(),
          style: TextStyle(
            color: data.accent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _StatWrap extends StatelessWidget {
  const _StatWrap({required this.data});

  final RecapSlideData data;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final stat in data.stats)
          _StatChip(value: stat.value, label: stat.label, color: data.accent),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 88, maxWidth: 160),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.data});

  final RecapSlideData data;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      strong: true,
      padding: const EdgeInsets.all(Spacing.md),
      child: Text(
        data.motivation,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 15,
          height: 1.45,
        ),
      ),
    );
  }
}
