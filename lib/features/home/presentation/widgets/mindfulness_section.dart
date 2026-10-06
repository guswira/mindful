import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../exercise/presentation/breathing_picker_sheet.dart';
import '../../../journal/presentation/journal_prompt_rows.dart';

/// Mindfulness glass card: write today's plan, review today (both open
/// the quick journal sheet on the matching journal type), or pick a
/// breathing exercise to start. See SPEC.md Home Screen.
class MindfulnessSection extends StatelessWidget {
  const MindfulnessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const JournalPromptRows(),
          const PromptRowDivider(),
          PromptRow(
            icon: Icons.air_rounded,
            iconColor: glass.exerciseAccent,
            title: l10n.homeMindfulBreathingTitle,
            subtitle: l10n.homeMindfulBreathingSubtitle,
            pillLabel: l10n.homeMindfulBreathingAction,
            pillColor: glass.exerciseAccent,
            onTap: () => pickBreathingExercise(context),
          ),
        ],
      ),
    );
  }
}
