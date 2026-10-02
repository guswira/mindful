import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:mindful/features/exercise/data/ambience_player.dart';
import 'package:mindful/features/exercise/data/breathing_preferences_repository.dart';
import 'package:mindful/features/exercise/data/breathing_voice.dart';
import 'package:mindful/features/exercise/data/keep_screen_on.dart';
import 'package:mindful/features/exercise/data/supabase_breathing_datasource.dart';
import 'package:mindful/features/exercise/domain/breathing_exercise.dart';
import 'package:mindful/features/exercise/domain/breathing_preferences.dart';
import 'package:mindful/features/exercise/domain/breathing_session.dart';

/// An in-memory Hive box — only the members the repositories use.
class FakeBox extends Fake implements Box<dynamic> {
  final Map<dynamic, dynamic> data = {};

  @override
  Iterable<dynamic> get values => data.values;

  @override
  Future<void> put(dynamic key, dynamic value) async => data[key] = value;

  @override
  Future<int> clear() async {
    final count = data.length;
    data.clear();
    return count;
  }
}

/// Records saves; throws from every call while [failing].
class FakeBreathingDatasource extends Fake
    implements SupabaseBreathingDatasource {
  FakeBreathingDatasource({this.remote = const []});

  List<BreathingSession> remote;
  bool failing = false;
  final List<BreathingSession> saved = [];

  @override
  Future<List<BreathingSession>> getSessions() async {
    if (failing) throw Exception('offline');
    return remote;
  }

  @override
  Future<void> saveSession(BreathingSession session) async {
    if (failing) throw Exception('offline');
    saved.add(session);
  }
}

class FakePreferencesRepository extends Fake
    implements BreathingPreferencesRepository {
  FakePreferencesRepository([
    this.stored = const BreathingPreferences(voiceEnabled: false),
  ]);

  BreathingPreferences stored;

  @override
  Future<BreathingPreferences> read() async => stored;

  @override
  Future<void> write(BreathingPreferences preferences) async =>
      stored = preferences;
}

class FakeVoice extends Fake implements BreathingVoice {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text, {required double volume}) async =>
      spoken.add(text);

  @override
  Future<void> stop() async {}
}

class FakeAmbience extends Fake implements AmbiencePlayer {
  AmbienceTrack? playing;

  @override
  Future<void> play(AmbienceTrack track, double volume) async =>
      playing = track == AmbienceTrack.none ? null : track;

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async => playing = null;
}

class FakeKeepScreenOn extends Fake implements KeepScreenOn {
  bool enabled = false;

  @override
  Future<void> set({required bool enabled}) async => this.enabled = enabled;
}

/// A finished session started at [startedAt] lasting [seconds].
BreathingSession testSession({
  required String id,
  required DateTime startedAt,
  int seconds = 60,
}) => BreathingSession(
  id: id,
  userId: 'u1',
  exercise: BreathingExercise.box,
  startedAt: startedAt,
  durationSeconds: seconds,
  cycles: 3,
  createdAt: startedAt,
);
