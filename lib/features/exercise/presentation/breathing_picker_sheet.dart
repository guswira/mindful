import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../shared/widgets/glass_bottom_sheet.dart';
import '../../../shared/widgets/sheet_header.dart';
import '../domain/breathing_exercise.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';
import 'breathing_labels.dart';
import 'exercise_providers.dart';

/// Opens [BreathingPickerSheet] and pushes the session for the exercise
/// picked; does nothing if the sheet is dismissed.
Future<void> pickBreathingExercise(BuildContext context) async {
  final exercise = await showGlassBottomSheet<BreathingExercise>(
    context: context,
    builder: (_) => const BreathingPickerSheet(),
  );
  if (!context.mounted || exercise == null) {
    return;
  }
  await context.push('/exercise/breathing/${exercise.name}');
}

/// Lists the breathing exercises and pops with the one tapped — the
/// caller pushes its session. Opened from home's Mindfulness and Be
/// mindful sections.
class BreathingPickerSheet extends ConsumerWidget {
  const BreathingPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom =
        ref.watch(breathingPreferencesControllerProvider).valueOrNull?.custom ??
        const CustomBreathing();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: context.l10n.breathingPickerTitle,
            onClose: () => Navigator.pop(context),
          ),
          for (final exercise in BreathingExercise.values)
            _ExerciseTile(
              exercise: exercise,
              pattern: BreathingPattern.forExercise(exercise, custom),
            ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.pattern});

  final BreathingExercise exercise;
  final BreathingPattern pattern;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    final l10n = context.l10n;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(exerciseIcon(exercise), color: glass.exerciseAccent),
      title: Text(
        l10n.exerciseName(exercise),
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        l10n.patternSummary(pattern),
        style: TextStyle(color: glass.exerciseAccent),
      ),
      trailing: Icon(Icons.play_arrow_rounded, color: glass.exerciseAccent),
      onTap: () => Navigator.pop(context, exercise),
    );
  }
}
