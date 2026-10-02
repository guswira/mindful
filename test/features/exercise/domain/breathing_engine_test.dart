import 'package:flutter_test/flutter_test.dart';

import 'package:mindful/features/exercise/domain/breathing_engine.dart';
import 'package:mindful/features/exercise/domain/breathing_exercise.dart';
import 'package:mindful/features/exercise/domain/breathing_pattern.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';

void main() {
  const second = Duration(seconds: 1);

  group('BreathingEngine', () {
    test('moves through box breathing and counts a cycle per lap', () {
      final engine = BreathingEngine(BreathingPattern.box);

      expect(engine.phase.type, BreathPhaseType.inhale);
      expect(engine.phaseCounter, 4);

      expect(engine.tick(second * 3), isFalse);
      expect(engine.phaseCounter, 1);
      expect(engine.tick(second), isTrue);
      expect(engine.phase.type, BreathPhaseType.hold);

      engine.tick(second * 12);
      expect(engine.cycles, 1);
      expect(engine.phase.type, BreathPhaseType.inhale);
      expect(engine.elapsed, second * 16);
    });

    test('a long tick carries over across several steps', () {
      final engine = BreathingEngine(BreathingPattern.fourSevenEight)
        ..tick(const Duration(seconds: 12));

      expect(engine.phase.type, BreathPhaseType.exhale);
      expect(engine.phaseElapsed, second);
    });

    test('fullness grows on inhale, holds full, shrinks on release', () {
      final engine = BreathingEngine(BreathingPattern.fourSevenEight)
        ..tick(second * 2);
      expect(engine.fullness, closeTo(0.5, 1e-9));

      engine.tick(second * 3);
      expect(engine.fullness, 1);

      // 11s: the 7s hold has just ended, the release starts from full.
      engine.tick(second * 6);
      expect(engine.phase.type, BreathPhaseType.exhale);
      expect(engine.fullness, 1);
      engine.tick(second * 4);
      expect(engine.fullness, closeTo(0.5, 1e-9));
    });

    test('an open-ended hold waits for release and records the best', () {
      final engine = BreathingEngine(BreathingPattern.holdTest)
        ..tick(second * 5);
      expect(engine.phase.isOpenEnded, isTrue);

      engine.tick(const Duration(minutes: 5));
      expect(engine.phase.isOpenEnded, isTrue);
      expect(engine.phaseCounter, 300);

      expect(engine.release(), isTrue);
      expect(engine.phase.type, BreathPhaseType.exhale);
      expect(engine.bestHold, const Duration(minutes: 5));

      engine.tick(second * 25);
      expect(engine.cycles, 1);
      engine
        ..tick(second * 5)
        ..tick(second * 40)
        ..release();
      expect(engine.lastHold, second * 40);
      expect(engine.bestHold, const Duration(minutes: 5));
    });

    test('release does nothing during a timed step', () {
      final engine = BreathingEngine(BreathingPattern.equal);

      expect(engine.release(), isFalse);
      expect(engine.phase.type, BreathPhaseType.inhale);
    });
  });

  group('BreathingPattern.custom', () {
    test('drops 0-second holds and clamps counts into range', () {
      final pattern = BreathingPattern.custom(
        const CustomBreathing(inhale: 0, hold: 0, exhale: 99, holdAfter: 3),
      );

      expect(pattern.phases.map((phase) => phase.type), [
        BreathPhaseType.inhale,
        BreathPhaseType.exhale,
        BreathPhaseType.holdEmpty,
      ]);
      expect(pattern.phases.map((phase) => phase.seconds), [
        CustomBreathing.minBreath,
        CustomBreathing.maxSeconds,
        3,
      ]);
    });

    test('forExercise uses the saved counts only for Customize', () {
      const custom = CustomBreathing(inhale: 5, hold: 0, exhale: 5);

      expect(
        BreathingPattern.forExercise(
          BreathingExercise.custom,
          custom,
        ).cycleSeconds,
        10,
      );
      expect(
        BreathingPattern.forExercise(BreathingExercise.box, custom),
        same(BreathingPattern.box),
      );
    });
  });
}
