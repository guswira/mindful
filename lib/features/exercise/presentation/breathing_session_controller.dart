import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../data/ambience_player.dart';
import '../data/breathing_voice.dart';
import '../data/keep_screen_on.dart';
import '../domain/breathing_engine.dart';
import '../domain/breathing_pattern.dart';
import '../domain/breathing_preferences.dart';

/// Where a session is in its lifecycle.
enum SessionStatus { idle, running, paused }

/// A ripple ring emitted from the breathing circle at [at] (session time),
/// [strong] when it marks a completed cycle rather than a step change.
class BreathRipple {
  const BreathRipple({required this.at, required this.strong});

  final Duration at;
  final bool strong;
}

/// What a session achieved, handed back by [BreathingSessionController.finish].
class BreathingSessionResult {
  const BreathingSessionResult({
    required this.startedAt,
    required this.duration,
    required this.cycles,
    required this.bestHold,
  });

  final DateTime startedAt;
  final Duration duration;
  final int cycles;
  final Duration? bestHold;
}

/// Runs one breathing session: ticks a [BreathingEngine] every frame
/// while running, announces each new step through [voice], loops the
/// ambience, and keeps the screen awake.
///
/// Notifies every frame while running — listen with a narrow
/// [ListenableBuilder] rather than rebuilding the whole screen.
class BreathingSessionController extends ChangeNotifier {
  BreathingSessionController({
    required TickerProvider vsync,
    required BreathingPattern pattern,
    required BreathingPreferences preferences,
    required this.phaseWord,
    required this.voice,
    required this.ambience,
    required this.keepScreenOn,
  }) : engine = BreathingEngine(pattern),
       _preferences = preferences {
    _ticker = vsync.createTicker(_onTick);
  }

  /// How long a ripple takes to expand and fade out.
  static const Duration rippleLifetime = Duration(milliseconds: 2400);

  final BreathingEngine engine;
  final String Function(BreathPhaseType type) phaseWord;
  final BreathingVoice voice;
  final AmbiencePlayer ambience;
  final KeepScreenOn keepScreenOn;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  BreathingPreferences _preferences;
  SessionStatus _status = SessionStatus.idle;
  DateTime? _startedAt;
  final List<BreathRipple> _ripples = [];

  SessionStatus get status => _status;

  /// Ripples still visible at the current session time, oldest first.
  List<BreathRipple> get ripples => List.unmodifiable(_ripples);

  /// Starts from the first step, announcing it straight away.
  void start() {
    if (_status != SessionStatus.idle) {
      return;
    }
    _startedAt = DateTime.now();
    _run();
    _announce(strong: false);
  }

  void pause() {
    if (_status != SessionStatus.running) {
      return;
    }
    _ticker.stop();
    _status = SessionStatus.paused;
    unawaited(voice.stop());
    unawaited(ambience.pause());
    unawaited(keepScreenOn.set(enabled: false));
    notifyListeners();
  }

  void resume() {
    if (_status != SessionStatus.paused) {
      return;
    }
    _run();
  }

  /// Ends the Breath Holding Test's open-ended hold.
  void release() {
    if (_status == SessionStatus.running && engine.release()) {
      _announce(strong: engine.phaseIndex == 0);
      notifyListeners();
    }
  }

  /// Applies sound changes made mid-session from the sound sheet.
  void applyPreferences(BreathingPreferences preferences) {
    final previous = _preferences;
    _preferences = preferences;
    if (!preferences.voiceEnabled && previous.voiceEnabled) {
      unawaited(voice.stop());
    }
    if (preferences.ambience != previous.ambience) {
      unawaited(
        _status == SessionStatus.running
            ? ambience.play(preferences.ambience, preferences.ambienceVolume)
            : ambience.stop(),
      );
    } else {
      unawaited(ambience.setVolume(preferences.ambienceVolume));
    }
  }

  /// Stops everything and reports the session, or null if it never
  /// started.
  BreathingSessionResult? finish() {
    final startedAt = _startedAt;
    _stopAll();
    _status = SessionStatus.idle;
    notifyListeners();
    if (startedAt == null) {
      return null;
    }
    return BreathingSessionResult(
      startedAt: startedAt,
      duration: engine.elapsed,
      cycles: engine.cycles,
      bestHold: engine.bestHold,
    );
  }

  void _run() {
    _status = SessionStatus.running;
    _lastTick = Duration.zero;
    _ticker.start();
    unawaited(
      ambience.play(_preferences.ambience, _preferences.ambienceVolume),
    );
    unawaited(keepScreenOn.set(enabled: true));
    notifyListeners();
  }

  void _onTick(Duration tickerElapsed) {
    final delta = tickerElapsed - _lastTick;
    _lastTick = tickerElapsed;
    final cyclesBefore = engine.cycles;
    if (engine.tick(delta)) {
      _announce(strong: engine.cycles > cyclesBefore);
    }
    _ripples.removeWhere(
      (ripple) => engine.elapsed - ripple.at > rippleLifetime,
    );
    notifyListeners();
  }

  void _announce({required bool strong}) {
    _ripples.add(BreathRipple(at: engine.elapsed, strong: strong));
    if (_preferences.voiceEnabled) {
      unawaited(
        voice.speak(
          phaseWord(engine.phase.type),
          volume: _preferences.voiceVolume,
        ),
      );
    }
  }

  void _stopAll() {
    _ticker.stop();
    _ripples.clear();
    unawaited(voice.stop());
    unawaited(ambience.stop());
    unawaited(keepScreenOn.set(enabled: false));
  }

  @override
  void dispose() {
    _stopAll();
    _ticker.dispose();
    super.dispose();
  }
}
