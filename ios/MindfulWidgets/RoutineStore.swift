//
//  RoutineStore.swift
//  MindfulWidgets
//
//  Widget data (routines, tasks, labels) as pushed by `widget_service.dart`
//  into the shared App Group, plus the optimistic updates and tap queue
//  the routine intents write (from any widget). The extension can't reach Hive or Supabase, so a
//  tap only flips the shared copy and queues the change; the app replays
//  the queue (`widget_habit_log_sync.dart`) next time it opens or resumes.
//  See SPEC.md Home and Lock Screen Widgets.
//

import Foundation

let appGroupId = "group.com.guswira.mindful.widget"

/// One routine (habit) row of the `habits` JSON written by
/// `WidgetService._habitJson`. Keys the widget doesn't use are ignored.
struct WidgetRoutine: Codable, Identifiable, Hashable {
  let id: String
  let name: String
  let icon: String
  var color: String?
  let actions: [String]
  var isCompleted: Bool
  var completedActionLabel: String?
}

/// One row of the `tasks` JSON written by `widget_service.dart`.
struct WidgetTask: Codable, Identifiable, Hashable {
  let id: String
  let name: String
  let isCompleted: Bool
}

/// Copy pushed by `widget_service.dart` in the app's language, with
/// English fallbacks for before the app has run once.
struct WidgetLabels {
  let tasks: String
  let routines: String
  let showMe: String
  let chooseTasks: String
  let chooseRoutines: String
  let done: String
  let allDone: String
  let noRoutines: String
  /// `{done}`/`{total}` tokens — counts can change after a lock screen
  /// tap, so the app's pre-filled labelHabitsCount may be stale.
  private let doneCountFormat: String
  /// `{count}` token.
  private let remainingFormat: String

  func doneCount(_ done: Int, of total: Int) -> String {
    doneCountFormat
      .replacingOccurrences(of: "{done}", with: "\(done)")
      .replacingOccurrences(of: "{total}", with: "\(total)")
  }

  func remaining(_ count: Int) -> String {
    remainingFormat.replacingOccurrences(of: "{count}", with: "\(count)")
  }

  static var current: WidgetLabels {
    let data = UserDefaults(suiteName: appGroupId)
    func label(_ key: String, _ fallback: String) -> String {
      data?.string(forKey: key) ?? fallback
    }
    return WidgetLabels(
      tasks: label("labelTasks", "Todo"),
      routines: label("labelHabits", "Routines"),
      showMe: label("labelShowMe", "Show me:"),
      chooseTasks: label("labelChooseTasks", "Todo"),
      chooseRoutines: label("labelChooseHabits", "Routines"),
      done: label("labelRoutineDone", "Done"),
      allDone: label("labelRoutinesAllDone", "All done"),
      noRoutines: label("labelNoRoutines", "No routines yet"),
      doneCountFormat: label("labelDoneCountFormat", "{done}/{total} done"),
      remainingFormat: label("labelRemainingFormat", "{count} remaining")
    )
  }
}

/// The small widget's list, shared by every small widget like on Android.
enum SmallWidgetMode: String {
  case tasks
  case habits
}

/// Everything the home screen widgets show, read in one go.
struct WidgetSnapshot {
  let routines: [WidgetRoutine]
  let tasks: [WidgetTask]
  let tasksDone: Int
  let tasksTotal: Int
  /// nil until picked — shows the chooser, like Android's first add.
  let smallMode: SmallWidgetMode?
  let labels: WidgetLabels

  var routinesDone: Int { routines.filter(\.isCompleted).count }

  static func current() -> WidgetSnapshot {
    let data = UserDefaults(suiteName: appGroupId)
    let tasks =
      data?.string(forKey: "tasks")
      .flatMap { try? JSONDecoder().decode([WidgetTask].self, from: Data($0.utf8)) } ?? []
    return WidgetSnapshot(
      // From RoutineStore rather than habitsDone, so lock screen taps and
      // the midnight reset show before the app next runs.
      routines: RoutineStore.routines(),
      tasks: tasks,
      tasksDone: data?.integer(forKey: "tasksDone") ?? 0,
      tasksTotal: data?.integer(forKey: "tasksTotal") ?? 0,
      smallMode: data?.string(forKey: "smallWidgetMode").flatMap(SmallWidgetMode.init(rawValue:)),
      labels: .current
    )
  }

  static let placeholder = WidgetSnapshot(
    routines: [
      WidgetRoutine(
        id: "1", name: "Workout", icon: "🏋️", actions: ["Gym", "Run"],
        isCompleted: false),
      WidgetRoutine(id: "2", name: "Meditate", icon: "🧘", actions: [], isCompleted: true),
      WidgetRoutine(id: "3", name: "Read", icon: "📚", actions: [], isCompleted: false),
    ],
    tasks: [
      WidgetTask(id: "1", name: "Buy groceries", isCompleted: false),
      WidgetTask(id: "2", name: "Renew passport", isCompleted: true),
    ],
    tasksDone: 1,
    tasksTotal: 2,
    smallMode: .habits,
    labels: .current
  )
}

enum RoutineStore {
  private static let habitsKey = "habits"
  private static let habitsDateKey = "habitsDate"
  private static let habitsDoneKey = "habitsDone"
  /// Read and cleared by `widget_habit_log_sync.dart`.
  private static let pendingKey = "pendingHabitLogs"
  private static let smallModeKey = "smallWidgetMode"

  private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

  /// Today's routines. Completion pushed on an earlier day (the app hasn't
  /// run since midnight) reads as not done, the same as the app would.
  static func routines(now: Date = Date()) -> [WidgetRoutine] {
    guard
      let json = defaults?.string(forKey: habitsKey),
      let routines = try? JSONDecoder().decode([WidgetRoutine].self, from: Data(json.utf8))
    else {
      return []
    }
    guard defaults?.string(forKey: habitsDateKey) == dayKey(now) else {
      return routines.map { routine in
        var reset = routine
        reset.isCompleted = false
        reset.completedActionLabel = nil
        return reset
      }
    }
    return routines
  }

  /// Marks [habitId] done today via [actionLabel] (nil = plain "done").
  static func log(habitId: String, actionLabel: String?, now: Date = Date()) {
    update(habitId: habitId, now: now) { routine in
      routine.isCompleted = true
      routine.completedActionLabel = actionLabel
    }
    enqueue(habitId: habitId, actionLabel: actionLabel, undo: false, now: now)
  }

  /// Undoes today's log for [habitId].
  static func unlog(habitId: String, now: Date = Date()) {
    update(habitId: habitId, now: now) { routine in
      routine.isCompleted = false
      routine.completedActionLabel = nil
    }
    enqueue(habitId: habitId, actionLabel: nil, undo: true, now: now)
  }

  /// The small widget chooser's pick. Dart reads it back on its next write
  /// (`WidgetService._getSmallWidgetMode`), so it sticks.
  static func setSmallMode(_ mode: SmallWidgetMode) {
    defaults?.set(mode.rawValue, forKey: smallModeKey)
  }

  /// `yyyy-MM-dd` local day — matches Dart's `widgetDateKey`.
  static func dayKey(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  private static func update(
    habitId: String,
    now: Date,
    _ change: (inout WidgetRoutine) -> Void
  ) {
    // Day-normalized first, so a tap after midnight doesn't bring back
    // yesterday's checks once the date is restamped below.
    var routines = routines(now: now)
    guard let index = routines.firstIndex(where: { $0.id == habitId }) else {
      return
    }
    change(&routines[index])
    guard let data = try? JSONEncoder().encode(routines) else {
      return
    }
    defaults?.set(String(decoding: data, as: UTF8.self), forKey: habitsKey)
    defaults?.set(dayKey(now), forKey: habitsDateKey)
    defaults?.set(routines.filter(\.isCompleted).count, forKey: habitsDoneKey)
  }

  private static func enqueue(habitId: String, actionLabel: String?, undo: Bool, now: Date) {
    var queue: [Any] = []
    if let json = defaults?.string(forKey: pendingKey),
      let existing = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [Any]
    {
      queue = existing
    }
    queue.append([
      "habitId": habitId,
      "date": dayKey(now),
      "actionLabel": actionLabel ?? NSNull(),
      "undo": undo,
    ] as [String: Any])
    guard let data = try? JSONSerialization.data(withJSONObject: queue) else {
      return
    }
    defaults?.set(String(decoding: data, as: UTF8.self), forKey: pendingKey)
  }
}
