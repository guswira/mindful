import 'breathing_session.dart';

/// Sessions and time spent on one calendar day.
class DayActivity {
  const DayActivity({required this.sessions, required this.time});

  final int sessions;
  final Duration time;
}

/// All-time totals plus per-day activity for the Exercise tab.
class ExerciseStats {
  const ExerciseStats({
    required this.totalSessions,
    required this.totalTime,
    required this.currentStreak,
    required this.byDay,
  });

  static const empty = ExerciseStats(
    totalSessions: 0,
    totalTime: Duration.zero,
    currentStreak: 0,
    byDay: {},
  );

  final int totalSessions;
  final Duration totalTime;

  /// Consecutive days with a session, ending today — or yesterday, so the
  /// streak doesn't read 0 all morning before today's session.
  final int currentStreak;

  /// Keyed by local date at midnight.
  final Map<DateTime, DayActivity> byDay;

  /// [month]'s totals (any day within it works).
  DayActivity monthActivity(DateTime month) {
    var sessions = 0;
    var time = Duration.zero;
    for (final MapEntry(key: day, value: activity) in byDay.entries) {
      if (day.year == month.year && day.month == month.month) {
        sessions += activity.sessions;
        time += activity.time;
      }
    }
    return DayActivity(sessions: sessions, time: time);
  }
}

/// Summarizes [sessions] as of [now] (local time).
ExerciseStats buildExerciseStats(
  List<BreathingSession> sessions,
  DateTime now,
) {
  final byDay = <DateTime, DayActivity>{};
  var totalTime = Duration.zero;
  for (final session in sessions) {
    final local = session.startedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final time = Duration(seconds: session.durationSeconds);
    totalTime += time;
    final previous = byDay[day];
    byDay[day] = DayActivity(
      sessions: (previous?.sessions ?? 0) + 1,
      time: (previous?.time ?? Duration.zero) + time,
    );
  }
  return ExerciseStats(
    totalSessions: sessions.length,
    totalTime: totalTime,
    currentStreak: _streak(byDay.keys.toSet(), now),
    byDay: byDay,
  );
}

int _streak(Set<DateTime> days, DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  if (!days.contains(day)) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}
