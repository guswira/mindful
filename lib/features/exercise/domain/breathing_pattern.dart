import 'breathing_exercise.dart';
import 'breathing_preferences.dart';

/// One step of a breathing cycle.
enum BreathPhaseType {
  inhale,

  /// Holding with full lungs.
  hold,
  exhale,

  /// Holding with empty lungs (box breathing's 4th side).
  holdEmpty,

  /// Breathing normally between Breath Holding Test rounds.
  rest,
}

/// A [type] step lasting [seconds], or until the user releases it when
/// [seconds] is null (the Breath Holding Test's hold).
class BreathPhase {
  const BreathPhase(this.type, this.seconds);

  const BreathPhase.untilRelease(this.type) : seconds = null;

  final BreathPhaseType type;
  final int? seconds;

  bool get isOpenEnded => seconds == null;
}

/// The ordered steps of one breathing cycle. Never empty, and always has
/// at least one timed step longer than 0s, so a session always advances.
class BreathingPattern {
  const BreathingPattern(this.phases);

  /// The pattern [exercise] runs; [custom] only matters for
  /// [BreathingExercise.custom].
  factory BreathingPattern.forExercise(
    BreathingExercise exercise,
    CustomBreathing custom,
  ) => switch (exercise) {
    BreathingExercise.equal => equal,
    BreathingExercise.box => box,
    BreathingExercise.fourSevenEight => fourSevenEight,
    BreathingExercise.holdTest => holdTest,
    BreathingExercise.custom => BreathingPattern.custom(custom),
  };

  /// [custom]'s steps, dropping 0-second holds and clamping every count
  /// into its allowed range.
  factory BreathingPattern.custom(CustomBreathing custom) {
    int breath(int value) =>
        value.clamp(CustomBreathing.minBreath, CustomBreathing.maxSeconds);
    int hold(int value) => value.clamp(0, CustomBreathing.maxSeconds);
    return BreathingPattern([
      BreathPhase(BreathPhaseType.inhale, breath(custom.inhale)),
      if (hold(custom.hold) > 0)
        BreathPhase(BreathPhaseType.hold, hold(custom.hold)),
      BreathPhase(BreathPhaseType.exhale, breath(custom.exhale)),
      if (hold(custom.holdAfter) > 0)
        BreathPhase(BreathPhaseType.holdEmpty, hold(custom.holdAfter)),
    ]);
  }

  static const equal = BreathingPattern([
    BreathPhase(BreathPhaseType.inhale, 4),
    BreathPhase(BreathPhaseType.exhale, 4),
  ]);

  static const box = BreathingPattern([
    BreathPhase(BreathPhaseType.inhale, 4),
    BreathPhase(BreathPhaseType.hold, 4),
    BreathPhase(BreathPhaseType.exhale, 4),
    BreathPhase(BreathPhaseType.holdEmpty, 4),
  ]);

  static const fourSevenEight = BreathingPattern([
    BreathPhase(BreathPhaseType.inhale, 4),
    BreathPhase(BreathPhaseType.hold, 7),
    BreathPhase(BreathPhaseType.exhale, 8),
  ]);

  /// A deep breath, an open-ended hold, a slow release, then 20s of
  /// normal breathing so the next round doesn't start out of breath.
  static const holdTest = BreathingPattern([
    BreathPhase(BreathPhaseType.inhale, 5),
    BreathPhase.untilRelease(BreathPhaseType.hold),
    BreathPhase(BreathPhaseType.exhale, 5),
    BreathPhase(BreathPhaseType.rest, 20),
  ]);

  final List<BreathPhase> phases;

  /// Whether a step waits for the user to release it.
  bool get hasOpenEndedPhase => phases.any((phase) => phase.isOpenEnded);

  /// One cycle's length in seconds, counting open-ended steps as 0.
  int get cycleSeconds =>
      phases.fold(0, (total, phase) => total + (phase.seconds ?? 0));
}
