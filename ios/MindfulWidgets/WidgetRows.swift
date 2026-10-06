//
//  WidgetRows.swift
//  MindfulWidgets
//
//  Routine and task rows shared by the small and medium home screen
//  widgets — widget_habit_row.xml / widget_task_row.xml and their
//  factories (HabitWidgetFactory / TaskWidgetFactory) on Android. Routine
//  taps run RoutineIntents in place instead of opening the app; the
//  outcome is the same. See SPEC.md Home and Lock Screen Widgets.
//

import AppIntents
import SwiftUI
import WidgetKit

/// Icon + name, then a filled check (done → undo), action pills (→ log
/// that action), or an empty circle (no actions → plain "done").
struct RoutineRow: View {
  let routine: WidgetRoutine
  /// Android shows 2; a half-width iOS column (small widget, or medium next
  /// to Todo) only fits 1 beside a readable name.
  var maxPills = 2
  /// Small widgets can't route Links, so the actionless row's
  /// open-habit link is medium only.
  var linksToDetail = false

  /// The user's color for this routine — its icon, pills and check.
  private var tint: Color { routineColor(routine.color) ?? WidgetColors.habit }

  var body: some View {
    HStack(spacing: 0) {
      if linksToDetail && routine.actions.isEmpty {
        Link(destination: widgetLink("open-habit?habitId=\(routine.id)")) { label }
      } else {
        label
      }
      Spacer(minLength: 0)
      trailing
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 3)
  }

  private var label: some View {
    HStack(spacing: 8) {
      RoutineIcon(icon: routine.icon)
        .foregroundStyle(tint)
        .frame(width: 30, height: 30)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(tint.opacity(0.10))
            .strokeBorder(tint.opacity(0.15), lineWidth: 0.5))
      Text(routine.name)
        .font(.system(size: 14))
        .foregroundStyle(WidgetColors.textPrimary)
        .lineLimit(1)
    }
    // Sized before the spacer; the fixed-size pills still keep theirs.
    .layoutPriority(1)
  }

  @ViewBuilder private var trailing: some View {
    if routine.isCompleted {
      Button(intent: UnlogRoutineIntent(habitId: routine.id)) {
        checkImage("checkmark.circle.fill")
      }
      .buttonStyle(.plain)
    } else if routine.actions.isEmpty {
      Button(intent: LogRoutineIntent(habitId: routine.id, actionLabel: nil)) {
        checkImage("circle")
      }
      .buttonStyle(.plain)
    } else {
      ForEach(routine.actions.prefix(maxPills), id: \.self) { action in
        Button(intent: LogRoutineIntent(habitId: routine.id, actionLabel: action)) {
          ActionPill(title: action, color: tint)
        }
        .buttonStyle(.plain)
        .padding(.leading, 6)
      }
    }
  }

  private func checkImage(_ name: String) -> some View {
    Image(systemName: name)
      .font(.system(size: 20))
      .foregroundStyle(tint)
      .frame(width: 28, height: 28)
      .padding(.leading, 2)
  }
}

/// widget_action_pill.xml.
struct ActionPill: View {
  let title: String
  /// The routine's own color (habitAccent if it has none).
  var color: Color = WidgetColors.habit

  var body: some View {
    Text(title)
      .font(.system(size: 12))
      .foregroundStyle(color)
      .lineLimit(1)
      .fixedSize()
      .padding(.horizontal, 10)
      .padding(.vertical, 7)
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(color.opacity(0.10))
          .strokeBorder(color.opacity(0.15), lineWidth: 0.5))
  }
}

/// Name + check glyph (taskAccent when done). Not a toggle, like Android —
/// the medium widget's row opens the task's detail sheet.
struct TaskRow: View {
  let task: WidgetTask
  var linksToDetail = false

  var body: some View {
    if linksToDetail {
      Link(destination: widgetLink("open-task?taskId=\(task.id)")) { content }
    } else {
      content
    }
  }

  private var content: some View {
    HStack(spacing: 8) {
      Text(task.name)
        .font(.system(size: 14))
        .foregroundStyle(WidgetColors.textPrimary)
        .lineLimit(1)
      Spacer(minLength: 0)
      Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
        .font(.system(size: 16))
        .foregroundStyle(task.isCompleted ? WidgetColors.task : WidgetColors.taskTodoStroke)
        .frame(width: 20, height: 20)
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 3)
  }
}

/// A `mindful://` link home_widget forwards to Dart's
/// navigateFromWidgetUri — it only does so with a `homeWidget` query item.
func widgetLink(_ path: String) -> URL {
  let separator = path.contains("?") ? "&" : "?"
  return URL(string: "mindful://\(path)\(separator)homeWidget")!
}
