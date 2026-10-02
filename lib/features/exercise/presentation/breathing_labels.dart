import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/breathing_exercise.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';

/// Display copy for [BreathingExercise], [BreathPhaseType] and
/// [AmbienceTrack] values, and duration formatting for the Exercise tab.
extension BreathingLabels on AppLocalizations {
  String exerciseName(BreathingExercise exercise) => switch (exercise) {
    BreathingExercise.equal => breathingEqualName,
    BreathingExercise.box => breathingBoxName,
    BreathingExercise.fourSevenEight => breathing478Name,
    BreathingExercise.holdTest => breathingHoldTestName,
    BreathingExercise.custom => breathingCustomName,
  };

  String exerciseDescription(BreathingExercise exercise) => switch (exercise) {
    BreathingExercise.equal => breathingEqualDescription,
    BreathingExercise.box => breathingBoxDescription,
    BreathingExercise.fourSevenEight => breathing478Description,
    BreathingExercise.holdTest => breathingHoldTestDescription,
    BreathingExercise.custom => breathingCustomDescription,
  };

  /// Shown in the circle and spoken by the voice guide.
  String phaseWord(BreathPhaseType type) => switch (type) {
    BreathPhaseType.inhale => breathingPhaseInhale,
    BreathPhaseType.hold || BreathPhaseType.holdEmpty => breathingPhaseHold,
    BreathPhaseType.exhale => breathingPhaseExhale,
    BreathPhaseType.rest => breathingPhaseRest,
  };

  /// e.g. "Inhale 4s · Hold 7s · Release 8s".
  String patternSummary(BreathingPattern pattern) => [
    for (final phase in pattern.phases)
      if (phase.seconds case final seconds?)
        breathingPatternStep(phaseWord(phase.type), seconds)
      else
        breathingPatternStepOpen(phaseWord(phase.type)),
  ].join(' · ');

  String ambienceName(AmbienceTrack track) => switch (track) {
    AmbienceTrack.none => ambienceNone,
    AmbienceTrack.rain => ambienceRain,
    AmbienceTrack.ocean => ambienceOcean,
    AmbienceTrack.wind => ambienceWind,
    AmbienceTrack.drone => ambienceDrone,
  };

  /// Compact total time: "45s", "12m", "1h 5m".
  String exerciseDuration(Duration duration) {
    if (duration.inMinutes == 0) {
      return exerciseDurationSeconds(duration.inSeconds);
    }
    if (duration.inHours == 0) {
      return exerciseDurationMinutes(duration.inMinutes);
    }
    return exerciseDurationHours(
      duration.inHours,
      duration.inMinutes.remainder(60),
    );
  }
}

/// A running clock: "03:07", or "1:03:07" past an hour.
String formatSessionClock(Duration duration) {
  String two(int value) => value.toString().padLeft(2, '0');
  final minutes = two(duration.inMinutes.remainder(60));
  final seconds = two(duration.inSeconds.remainder(60));
  return duration.inHours > 0
      ? '${duration.inHours}:$minutes:$seconds'
      : '$minutes:$seconds';
}

/// The icon shown on each exercise's card.
IconData exerciseIcon(BreathingExercise exercise) => switch (exercise) {
  BreathingExercise.equal => Icons.balance_outlined,
  BreathingExercise.box => Icons.crop_square_outlined,
  BreathingExercise.fourSevenEight => Icons.bedtime_outlined,
  BreathingExercise.holdTest => Icons.timer_outlined,
  BreathingExercise.custom => Icons.tune_outlined,
};
