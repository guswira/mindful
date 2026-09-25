import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Serializes [TimeOfDay] as an "HH:mm" string for JSON storage.
class TimeOfDayConverter implements JsonConverter<TimeOfDay?, String?> {
  const TimeOfDayConverter();

  @override
  TimeOfDay? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String? toJson(TimeOfDay? object) {
    if (object == null) {
      return null;
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(object.hour)}:${twoDigits(object.minute)}';
  }
}
