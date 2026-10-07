// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';
import 'habit_tag.dart';

part 'habit_log.freezed.dart';
part 'habit_log.g.dart';

/// A single completion record for a habit on a given [date].
///
/// Serializes to/from `snake_case` to match the `habit_logs` Supabase table
/// directly.
@freezed
abstract class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'habit_id') required String habitId,
    required DateTime date,
    @JsonKey(name: 'completed_action_id') String? completedActionId,
    String? note,

    /// How many times each tag (by [HabitTag.id]) was done that day, e.g.
    /// `{heavyId: 1, easyId: 3}`. Null until the log is first tagged —
    /// see [Habit.tags] for why. Read via [tagCounts].
    @JsonKey(includeIfNull: false) Map<String, int>? tags,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _HabitLog;

  const HabitLog._();

  factory HabitLog.fromJson(Map<String, dynamic> json) =>
      _$HabitLogFromJson(json);

  /// [tags], or none.
  Map<String, int> get tagCounts => tags ?? const {};
}
