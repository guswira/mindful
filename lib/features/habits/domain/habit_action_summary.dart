import 'habit.dart';
import 'habit_action.dart';
import 'habit_log.dart';
import 'habit_tag.dart';

/// What a [HabitActionCount] row counts.
enum HabitActionCountKind {
  /// Logs of one of the habit's current actions.
  action,

  /// Plain "Done" logs, with no action — e.g. logged before the habit had
  /// any actions.
  plainDone,

  /// Logs of actions that have since been removed from the habit.
  removed,
}

/// One row of a habit's monthly action summary. [action] is set only for
/// [HabitActionCountKind.action].
typedef HabitActionCount = ({
  HabitActionCountKind kind,
  HabitAction? action,
  int count,
});

/// How many times each of [habit]'s actions was logged in [month].
///
/// Every current action gets a row, in the habit's order, even at 0 — so
/// an action never done this month still shows up. Plain "Done" and
/// removed-action logs follow, only when there are any.
List<HabitActionCount> countActionsInMonth(
  Habit habit,
  Iterable<HabitLog> logs,
  DateTime month,
) {
  final counts = <String?, int>{};
  for (final log in logs) {
    if (log.habitId == habit.id &&
        log.date.year == month.year &&
        log.date.month == month.month) {
      counts.update(log.completedActionId, (n) => n + 1, ifAbsent: () => 1);
    }
  }

  final known = {for (final action in habit.actions) action.id};
  final plainDone = counts[null] ?? 0;
  final removed = counts.entries
      .where((entry) => entry.key != null && !known.contains(entry.key))
      .fold(0, (sum, entry) => sum + entry.value);

  return [
    for (final action in habit.actions)
      (
        kind: HabitActionCountKind.action,
        action: action,
        count: counts[action.id] ?? 0,
      ),
    if (plainDone > 0)
      (kind: HabitActionCountKind.plainDone, action: null, count: plainDone),
    if (removed > 0)
      (kind: HabitActionCountKind.removed, action: null, count: removed),
  ];
}

/// The action [log] recorded on [habit], or null for a plain "Done" log or
/// one whose action has since been removed.
HabitAction? actionForLog(Habit habit, HabitLog log) {
  for (final action in habit.actions) {
    if (action.id == log.completedActionId) {
      return action;
    }
  }
  return null;
}

/// One row of a habit's monthly tag summary: how many times [tag] was done.
typedef HabitTagCount = ({HabitTag tag, int count});

/// How many times each of [habit]'s tags was done in [month] — a log's
/// count per tag adds up, so "Easy ×3" on one day counts 3. Only logs
/// matching [where] count, when given (e.g. one action's logs).
///
/// Every current tag gets a row, in the habit's order, even at 0. Counts
/// for tags since removed from the habit are dropped.
List<HabitTagCount> countTagsInMonth(
  Habit habit,
  Iterable<HabitLog> logs,
  DateTime month, {
  bool Function(HabitLog log)? where,
}) {
  final counts = <String, int>{};
  for (final log in logs) {
    if (log.habitId == habit.id &&
        log.date.year == month.year &&
        log.date.month == month.month &&
        (where == null || where(log))) {
      for (final MapEntry(:key, :value) in log.tagCounts.entries) {
        counts.update(key, (n) => n + value, ifAbsent: () => value);
      }
    }
  }
  return [
    for (final tag in habit.tagList) (tag: tag, count: counts[tag.id] ?? 0),
  ];
}

/// [countTagsInMonth] split by action — keyed by [HabitAction.id], one
/// entry per current action of [habit].
Map<String, List<HabitTagCount>> countTagsByActionInMonth(
  Habit habit,
  Iterable<HabitLog> logs,
  DateTime month,
) => {
  for (final action in habit.actions)
    action.id: countTagsInMonth(
      habit,
      logs,
      month,
      where: (log) => log.completedActionId == action.id,
    ),
};
