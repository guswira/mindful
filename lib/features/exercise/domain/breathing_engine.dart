import 'breathing_pattern.dart';

/// The clock-free state machine behind a breathing session: which step
/// it's on, how far through it, and how many cycles are done.
///
/// Time only moves when [tick] is called, so pausing is just not ticking,
/// and tests can drive it deterministically.
class BreathingEngine {
  BreathingEngine(this.pattern);

  final BreathingPattern pattern;

  int _phaseIndex = 0;
  Duration _phaseElapsed = Duration.zero;
  Duration _elapsed = Duration.zero;
  int _cycles = 0;
  Duration? _lastHold;
  Duration? _bestHold;

  BreathPhase get phase => pattern.phases[_phaseIndex];

  /// Position of [phase] within the cycle — 0 is the cycle's first step.
  int get phaseIndex => _phaseIndex;

  /// Total time ticked so far.
  Duration get elapsed => _elapsed;

  /// Time spent in the current [phase].
  Duration get phaseElapsed => _phaseElapsed;

  /// Fully completed cycles.
  int get cycles => _cycles;

  /// The most recent / longest released open-ended hold, if any.
  Duration? get lastHold => _lastHold;
  Duration? get bestHold => _bestHold;

  /// 0 → 1 through a timed [phase]; always 0 for an open-ended one.
  double get phaseProgress {
    final seconds = phase.seconds;
    if (seconds == null || seconds == 0) {
      return 0;
    }
    final total = Duration(seconds: seconds).inMicroseconds;
    return (_phaseElapsed.inMicroseconds / total).clamp(0.0, 1.0);
  }

  /// The number shown inside the circle: whole seconds left in a timed
  /// step (counting down from its length), or whole seconds held so far
  /// in an open-ended one.
  int get phaseCounter {
    final seconds = phase.seconds;
    if (seconds == null) {
      return _phaseElapsed.inSeconds;
    }
    final left = Duration(seconds: seconds) - _phaseElapsed;
    return (left.inMicroseconds / Duration.microsecondsPerSecond).ceil();
  }

  /// How full the lungs are, 0 (empty) → 1 (full) — the breathing
  /// circle's size before easing.
  double get fullness => switch (phase.type) {
    BreathPhaseType.inhale => phaseProgress,
    BreathPhaseType.hold => 1,
    BreathPhaseType.exhale => 1 - phaseProgress,
    BreathPhaseType.holdEmpty || BreathPhaseType.rest => 0,
  };

  /// Advances the clock by [delta], moving through as many steps as it
  /// covers. Returns whether [phase] changed, so the caller can announce
  /// the new step.
  bool tick(Duration delta) {
    _elapsed += delta;
    _phaseElapsed += delta;
    var changed = false;
    while (true) {
      final seconds = phase.seconds;
      if (seconds == null) {
        break;
      }
      final length = Duration(seconds: seconds);
      if (_phaseElapsed < length) {
        break;
      }
      _phaseElapsed -= length;
      _advance();
      changed = true;
    }
    return changed;
  }

  /// Ends an open-ended hold, recording it in [lastHold]/[bestHold].
  /// Returns false (and does nothing) during a timed step.
  bool release() {
    if (!phase.isOpenEnded) {
      return false;
    }
    final held = _phaseElapsed;
    _lastHold = held;
    final best = _bestHold;
    if (best == null || held > best) {
      _bestHold = held;
    }
    _phaseElapsed = Duration.zero;
    _advance();
    return true;
  }

  void _advance() {
    _phaseIndex++;
    if (_phaseIndex >= pattern.phases.length) {
      _phaseIndex = 0;
      _cycles++;
    }
  }
}
