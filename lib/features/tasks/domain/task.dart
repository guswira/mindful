// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';
import 'task_checkbox.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// A to-do item with optional due date, reminder, and subtasks. See
/// SPEC.md Data models.
///
/// Serializes to/from `snake_case` to match the `tasks` Supabase table
/// directly.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'reminder_at') DateTime? reminderAt,
    @Default(<TaskCheckbox>[]) List<TaskCheckbox> checkboxes,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
