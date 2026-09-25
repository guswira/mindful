import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n.dart';

/// Generates a UUID for a new habit or habit action created in the
/// add/edit sheet. Habit ids are Supabase's `uuid` primary key; habit
/// action ids just need to be unique within their habit, but share the
/// same generator for simplicity.
String generateHabitFormId() => const Uuid().v4();

/// Reminder day labels, indexed 0=Mon..6=Sun per SPEC.md.
List<String> habitWeekdayLabels(AppLocalizations l10n) => [
  l10n.habitWeekdayMon,
  l10n.habitWeekdayTue,
  l10n.habitWeekdayWed,
  l10n.habitWeekdayThu,
  l10n.habitWeekdayFri,
  l10n.habitWeekdaySat,
  l10n.habitWeekdaySun,
];

/// Parses a "#RRGGBB" string (as stored on a habit's `color` field) into a
/// [Color].
Color parseHexColor(String hex) {
  final value = hex.startsWith('#') ? hex.substring(1) : hex;
  return Color(int.parse('FF$value', radix: 16));
}

/// [parseHexColor], falling back to [fallback] if [hex] isn't a valid
/// "#RRGGBB" string — e.g. the habitAccent default for the calendar dots
/// in [HabitDetailScreen]. See SPEC.md Habit Tracker.
Color parseHexColorOr(String hex, Color fallback) {
  try {
    return parseHexColor(hex);
  } on FormatException {
    return fallback;
  }
}
