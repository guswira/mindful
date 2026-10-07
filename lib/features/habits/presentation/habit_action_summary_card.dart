import 'package:flutter/material.dart';

import '../../../core/constants/spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/habit_action_summary.dart';

/// How many times each action was done in the shown month, one row per
/// action with a bar relative to the most-done one, and under it how that
/// action's days were tagged ("Heavy ×3 · Easy ×1").
class HabitActionSummaryCard extends StatelessWidget {
  const HabitActionSummaryCard({
    required this.counts,
    required this.color,
    this.tagsByAction = const {},
    super.key,
  });

  final List<HabitActionCount> counts;
  final Color color;

  /// Each action's tag counts, keyed by action id.
  final Map<String, List<HabitTagCount>> tagsByAction;

  /// [row]'s action's tags as "Heavy ×3 · Easy ×1", or null if none.
  String? _tagLine(AppLocalizations l10n, HabitActionCount row) {
    final tags = tagsByAction[row.action?.id] ?? const [];
    final parts = [
      for (final (:tag, :count) in tags)
        if (count > 0) l10n.habitTagTimes(tag.label, count),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final maxCount = counts.fold(
      0,
      (max, row) => row.count > max ? row.count : max,
    );
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.habitActionSummaryTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: glass.textMuted,
            ),
          ),
          for (final row in counts)
            _ActionCountRow(
              label: habitActionCountLabel(context.l10n, row),
              count: row.count,
              progress: maxCount == 0 ? 0 : row.count / maxCount,
              color: color,
              detail: _tagLine(context.l10n, row),
            ),
        ],
      ),
    );
  }
}

/// How many times each tag was done in the shown month — a day tagged
/// "Easy ×3" counts 3 — one row per tag with a bar relative to the
/// most-done one.
class HabitTagSummaryCard extends StatelessWidget {
  const HabitTagSummaryCard({
    required this.counts,
    required this.color,
    super.key,
  });

  final List<HabitTagCount> counts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final maxCount = counts.fold(
      0,
      (max, row) => row.count > max ? row.count : max,
    );
    return GlassCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.habitTagSummaryTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: glass.textMuted,
            ),
          ),
          for (final (:tag, :count) in counts)
            _ActionCountRow(
              label: tag.label,
              count: count,
              progress: maxCount == 0 ? 0 : count / maxCount,
              color: color,
            ),
        ],
      ),
    );
  }
}

/// The display label for a summary [row].
String habitActionCountLabel(AppLocalizations l10n, HabitActionCount row) =>
    switch (row.kind) {
      HabitActionCountKind.action => row.action?.label ?? l10n.commonDone,
      HabitActionCountKind.plainDone => l10n.commonDone,
      HabitActionCountKind.removed => l10n.habitActionRemoved,
    };

class _ActionCountRow extends StatelessWidget {
  const _ActionCountRow({
    required this.label,
    required this.count,
    required this.progress,
    required this.color,
    this.detail,
  });

  final String label;
  final int count;
  final double progress;
  final Color color;

  /// A muted line under the label, e.g. the action's tag counts.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              Text(
                context.l10n.habitActionSummaryCount(count),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: count == 0 ? glass.textMuted : color,
                ),
              ),
            ],
          ),
          if (detail case final detail?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                detail,
                style: TextStyle(fontSize: 12, color: glass.textMuted),
              ),
            ),
          const SizedBox(height: Spacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              color: color,
              backgroundColor: glass.cardColor,
            ),
          ),
        ],
      ),
    );
  }
}
