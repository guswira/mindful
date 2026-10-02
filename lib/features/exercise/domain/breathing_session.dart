// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';
import 'breathing_exercise.dart';

part 'breathing_session.freezed.dart';
part 'breathing_session.g.dart';

/// One finished breathing session. See SPEC.md Exercise.
///
/// Serializes to/from `snake_case` to match the `breathing_sessions`
/// Supabase table directly.
@freezed
abstract class BreathingSession with _$BreathingSession {
  const factory BreathingSession({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required BreathingExercise exercise,

    /// UTC — convert with `toLocal()` before grouping by day.
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
    required int cycles,
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Longest hold, for the Breath Holding Test only.
    @JsonKey(name: 'best_hold_seconds') int? bestHoldSeconds,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _BreathingSession;

  factory BreathingSession.fromJson(Map<String, dynamic> json) =>
      _$BreathingSessionFromJson(json);
}
