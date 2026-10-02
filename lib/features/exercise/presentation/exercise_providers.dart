import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/breathing_preferences_repository.dart';
import '../data/breathing_session_repository.dart';
import '../domain/breathing_preferences.dart';
import '../domain/breathing_session.dart';
import '../domain/exercise_stats.dart';

part 'exercise_providers.g.dart';

/// Every cached breathing session, newest first. Invalidate after saving
/// one so the tab's stats and calendar pick it up.
@riverpod
Future<List<BreathingSession>> breathingSessions(Ref ref) async {
  final repository = await ref.watch(breathingSessionRepositoryProvider.future);
  return repository.getSessions();
}

/// Totals, streak and per-day activity for the Exercise tab.
@riverpod
Future<ExerciseStats> exerciseStats(Ref ref) async {
  final sessions = await ref.watch(breathingSessionsProvider.future);
  return buildExerciseStats(sessions, DateTime.now());
}

/// Sound and Customize-pattern settings. Kept alive so a running session
/// and the sound sheet over it always share one copy.
@Riverpod(keepAlive: true)
class BreathingPreferencesController extends _$BreathingPreferencesController {
  @override
  Future<BreathingPreferences> build() =>
      ref.read(breathingPreferencesRepositoryProvider).read();

  /// Applies [preferences] without persisting — for a slider mid-drag,
  /// which [save]s once on release instead of on every frame.
  void preview(BreathingPreferences preferences) =>
      state = AsyncData(preferences);

  /// Applies [preferences] immediately, then persists them.
  Future<void> save(BreathingPreferences preferences) async {
    state = AsyncData(preferences);
    await ref.read(breathingPreferencesRepositoryProvider).write(preferences);
  }
}
