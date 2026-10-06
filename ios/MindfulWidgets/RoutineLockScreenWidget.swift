//
//  RoutineLockScreenWidget.swift
//  MindfulWidgets
//
//  Lock screen routines widget (iOS 17+, interactive; no Android
//  counterpart). Rectangular: a picked routine, or — with nothing picked —
//  the first 2 of today's routines, each with the home widgets' controls.
//  Circular: one routine's check. See SPEC.md Home and Lock Screen Widgets.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Entry + provider

struct RoutineEntry: TimelineEntry {
  let date: Date
  let routines: [WidgetRoutine]
  /// The configured routine; nil when none is picked or it no longer exists
  /// (deleted/archived), which falls back to the list.
  let picked: WidgetRoutine?
  let labels: WidgetLabels

  var doneCount: Int { routines.filter(\.isCompleted).count }

  /// Still-to-do first, so the few rows that fit show what's left.
  var listed: [WidgetRoutine] {
    routines.filter { !$0.isCompleted } + routines.filter(\.isCompleted)
  }

  /// The circular widget's routine: the picked one, else the next undone.
  var focus: WidgetRoutine? {
    picked ?? routines.first { !$0.isCompleted } ?? routines.first
  }

  static let placeholder = RoutineEntry(
    date: Date(),
    routines: [
      WidgetRoutine(
        id: "1", name: "Workout", icon: "🏋️", actions: ["Gym", "Run"],
        isCompleted: true, completedActionLabel: "Gym"),
      WidgetRoutine(
        id: "2", name: "Meditate", icon: "🧘", actions: [], isCompleted: false),
      WidgetRoutine(
        id: "3", name: "Read", icon: "📚", actions: [], isCompleted: false),
    ],
    picked: nil,
    labels: .current
  )
}

struct RoutineProvider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> RoutineEntry {
    .placeholder
  }

  func snapshot(for configuration: SelectRoutineIntent, in context: Context) async -> RoutineEntry {
    context.isPreview && RoutineStore.routines().isEmpty ? .placeholder : entry(configuration)
  }

  func timeline(for configuration: SelectRoutineIntent, in context: Context) async -> Timeline<RoutineEntry> {
    // Otherwise only reloaded by the app or a tap — redraw at midnight so
    // yesterday's checks clear even if neither happens.
    return Timeline(entries: [entry(configuration)], policy: .after(nextMidnight()))
  }

  private func entry(_ configuration: SelectRoutineIntent) -> RoutineEntry {
    let routines = RoutineStore.routines()
    let pickedId = configuration.routine?.id
    return RoutineEntry(
      date: Date(),
      routines: routines,
      picked: routines.first { $0.id == pickedId },
      labels: .current
    )
  }
}

// MARK: - Views
//
// Same tap rules as the home screen RoutineRow (and Android's habit row),
// in the lock screen's monochrome style: done → filled check (undo); with
// actions → up to 2 pills (log that action); no actions → empty circle
// (plain "done").

/// The row's trailing control.
struct LockRoutineControl: View {
  let routine: WidgetRoutine

  var body: some View {
    if routine.isCompleted {
      Button(intent: UnlogRoutineIntent(habitId: routine.id)) {
        Image(systemName: "checkmark.circle.fill").widgetAccentable()
      }
      .buttonStyle(.plain)
    } else if routine.actions.isEmpty {
      Button(intent: LogRoutineIntent(habitId: routine.id, actionLabel: nil)) {
        Image(systemName: "circle")
      }
      .buttonStyle(.plain)
    } else {
      HStack(spacing: 4) {
        ForEach(routine.actions.prefix(2), id: \.self) { action in
          Button(intent: LogRoutineIntent(habitId: routine.id, actionLabel: action)) {
            LockActionPill(title: action)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
}

struct LockActionPill: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.caption2.weight(.semibold))
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .padding(.horizontal, 6)
      .padding(.vertical, 2)
      .background(Capsule().strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
  }
}

/// Rectangular, one picked routine: name + control; when done via an
/// action, that action's name underneath.
struct PickedRoutineView: View {
  let routine: WidgetRoutine

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 4) {
        Label {
          Text(routine.name).lineLimit(1)
        } icon: {
          RoutineIcon(icon: routine.icon, size: 15)
        }
        .font(.headline)
        Spacer(minLength: 0)
        if routine.isCompleted || routine.actions.isEmpty {
          LockRoutineControl(routine: routine)
        }
      }
      if !routine.isCompleted && !routine.actions.isEmpty {
        LockRoutineControl(routine: routine)
      } else if let action = routine.completedActionLabel {
        Text(action).font(.caption).widgetAccentable()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

/// Rectangular, nothing picked: "Routines X/Y" + the first 2 rows.
struct RoutineListView: View {
  let entry: RoutineEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Text(entry.labels.routines).font(.headline)
        Spacer(minLength: 0)
        Text("\(entry.doneCount)/\(entry.routines.count)").widgetAccentable()
      }
      if entry.routines.isEmpty {
        Text(entry.labels.noRoutines).font(.caption)
      } else if entry.doneCount == entry.routines.count {
        Text(entry.labels.allDone).font(.caption)
      } else {
        ForEach(entry.listed.prefix(2)) { routine in
          HStack(spacing: 4) {
            Label {
              Text(routine.name).lineLimit(1)
            } icon: {
              RoutineIcon(icon: routine.icon, size: 11)
            }
            Spacer(minLength: 0)
            LockRoutineControl(routine: routine)
          }
          .font(.caption)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

/// Circular: the focus routine's icon inside a ring; tap → plain "done" /
/// undo (no room for action pills).
struct RoutineCircularView: View {
  let entry: RoutineEntry

  var body: some View {
    if let routine = entry.focus {
      Group {
        if routine.isCompleted {
          Button(intent: UnlogRoutineIntent(habitId: routine.id)) { face(routine) }
        } else {
          Button(intent: LogRoutineIntent(habitId: routine.id, actionLabel: nil)) { face(routine) }
        }
      }
      .buttonStyle(.plain)
    } else {
      Image(systemName: "checklist")
    }
  }

  private func face(_ routine: WidgetRoutine) -> some View {
    ZStack {
      Circle()
        .strokeBorder(lineWidth: routine.isCompleted ? 4 : 1.5)
        .widgetAccentable()
      RoutineIcon(icon: routine.icon, size: 20)
      if routine.isCompleted {
        Image(systemName: "checkmark.circle.fill")
          .font(.caption)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
          .widgetAccentable()
      }
    }
  }
}

struct RoutineLockScreenWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: RoutineEntry

  var body: some View {
    Group {
      switch family {
      case .accessoryCircular:
        RoutineCircularView(entry: entry)
      default:
        if let picked = entry.picked {
          PickedRoutineView(routine: picked)
        } else {
          RoutineListView(entry: entry)
        }
      }
    }
    // Taps outside a button open the Tasks & Routines tab.
    .widgetURL(widgetLink("home/habits"))
    .containerBackground(for: .widget) { Color.clear }
  }
}

// MARK: - Widget

struct MindfulRoutineLockScreenWidget: Widget {
  /// Must match `WidgetProviderNames.iOSRoutineLockScreenWidget`.
  let kind: String = "MindfulRoutineLockScreenWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind, intent: SelectRoutineIntent.self, provider: RoutineProvider()
    ) { entry in
      RoutineLockScreenWidgetView(entry: entry)
    }
    .configurationDisplayName("Mindful Routines")
    .description("Check off today's routines or pick an action, right from the lock screen.")
    .supportedFamilies([.accessoryRectangular, .accessoryCircular])
  }
}

#Preview(as: .accessoryRectangular) {
  MindfulRoutineLockScreenWidget()
} timeline: {
  RoutineEntry.placeholder
}
