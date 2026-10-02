import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../breathing_labels.dart';
import '../breathing_session_controller.dart';

/// Time elapsed and cycle count for the running session — plus the best
/// hold so far, for patterns with an open-ended hold.
class SessionStatsRow extends StatelessWidget {
  const SessionStatsRow({required this.controller, super.key});

  final BreathingSessionController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final engine = controller.engine;
        final bestHold = engine.bestHold;
        return Row(
          children: [
            _Stat(
              label: l10n.breathingElapsed,
              value: formatSessionClock(engine.elapsed),
            ),
            const SizedBox(width: Spacing.sm),
            _Stat(label: l10n.breathingCycles, value: '${engine.cycles}'),
            if (engine.pattern.hasOpenEndedPhase) ...[
              const SizedBox(width: Spacing.sm),
              _Stat(
                label: l10n.breathingBestHold,
                value: bestHold == null ? '–' : formatSessionClock(bestHold),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: glass.exerciseAccent,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: glass.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
