import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../journal/presentation/journal_prompt_rows.dart';
import '../../domain/breathing_exercise.dart';
import '../../domain/breathing_pattern.dart';
import '../../domain/breathing_preferences.dart';
import '../custom_pattern_sheet.dart';
import '../exercise_providers.dart';
import 'breathing_exercise_row.dart';

/// The Mindfulness tab's breathing half: "Breathing exercise" + "History"
/// (activity calendar), then one glass card listing the first
/// [collapsedCount] exercises with a "Show all (N more)" row that expands
/// it to every exercise.
class BreathingSection extends ConsumerStatefulWidget {
  const BreathingSection({super.key});

  /// Exercises shown before "Show all" is tapped.
  static const int collapsedCount = 3;

  @override
  ConsumerState<BreathingSection> createState() => _BreathingSectionState();
}

class _BreathingSectionState extends ConsumerState<BreathingSection> {
  bool _expanded = false;

  static final int _hiddenCount =
      BreathingExercise.values.length - BreathingSection.collapsedCount;

  List<BreathingExercise> get _visible => _expanded
      ? BreathingExercise.values
      : BreathingExercise.values.take(BreathingSection.collapsedCount).toList();

  void _start(BreathingExercise exercise) =>
      context.push('/exercise/breathing/${exercise.name}');

  void _editCustom(CustomBreathing custom) => showGlassBottomSheet<bool>(
    context: context,
    builder: (_) => CustomPatternSheet(initial: custom),
  );

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final custom =
        ref.watch(breathingPreferencesControllerProvider).valueOrNull?.custom ??
        const CustomBreathing();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.exerciseBreathingSection,
            titleColor: glass.exerciseAccent,
            actionLabel: l10n.exerciseHistory,
            onAction: () => context.push('/exercise/activity'),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (final (index, exercise) in _visible.indexed) ...[
                    if (index > 0) const PromptRowDivider(),
                    _row(exercise, custom),
                  ],
                  if (_hiddenCount > 0) ...[
                    const PromptRowDivider(),
                    _ShowAllRow(
                      label: _expanded
                          ? l10n.exerciseShowLess
                          : l10n.exerciseShowAll(_hiddenCount),
                      expanded: _expanded,
                      onTap: _toggleExpanded,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BreathingExercise exercise, CustomBreathing custom) =>
      BreathingExerciseRow(
        exercise: exercise,
        pattern: BreathingPattern.forExercise(exercise, custom),
        onStart: () => _start(exercise),
        onEdit: exercise == BreathingExercise.custom
            ? () => _editCustom(custom)
            : null,
      );
}

/// Bottom row of the card that expands / collapses the exercise list.
class _ShowAllRow extends StatelessWidget {
  const _ShowAllRow({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: glass.exerciseAccent),
              ),
              const SizedBox(width: 4),
              Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: glass.exerciseAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
