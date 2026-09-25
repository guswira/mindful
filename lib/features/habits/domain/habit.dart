// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/time_of_day_converter.dart';
import 'habit_action.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

/// A trackable habit: its display, custom completion actions, and reminder
/// schedule. See SPEC.md Data models.
///
/// Serializes to/from `snake_case` to match the `habits` Supabase table
/// directly.
@freezed
abstract class Habit with _$Habit {
  const factory Habit({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required String icon,
    required String color,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'reminder_days') @Default(<int>[]) List<int> reminderDays,
    @JsonKey(name: 'reminder_time')
    @TimeOfDayConverter()
    TimeOfDay? reminderTime,
    @Default(<HabitAction>[]) List<HabitAction> actions,
    @Default(false) bool archived,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}
