//
//  MindfulWidgets.swift
//  MindfulWidgets
//
//  Home screen widgets, mirroring Android's (MindfulMediumWidget.kt /
//  MindfulSmallWidget.kt), the circular routine-count lock screen widget
//  and the bundle. Data is written by `widget_service.dart` via
//  `home_widget`'s shared App Group container; rows are in
//  WidgetRows.swift, the interactive routines lock screen widget in
//  RoutineLockScreenWidget.swift. See SPEC.md Home and Lock Screen Widgets.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Entry + provider

struct MindfulEntry: TimelineEntry {
  let date: Date
  let data: WidgetSnapshot

  static let placeholder = MindfulEntry(date: Date(), data: .placeholder)
}

struct MindfulProvider: TimelineProvider {
  func placeholder(in context: Context) -> MindfulEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (MindfulEntry) -> Void) {
    let data = WidgetSnapshot.current()
    completion(
      context.isPreview && data.routines.isEmpty && data.tasks.isEmpty
        ? .placeholder : MindfulEntry(date: Date(), data: data))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<MindfulEntry>) -> Void) {
    // Reloaded by the app's updateWidget() and by routine taps; midnight is
    // the one change neither covers.
    let entry = MindfulEntry(date: Date(), data: .current())
    completion(Timeline(entries: [entry], policy: .after(nextMidnight())))
  }
}

func nextMidnight() -> Date {
  Calendar.current.date(
    byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
}

// MARK: - Medium (4x2): Routines | Todo + pencil

// Android's lists scroll; iOS widgets can't, so only what fits inside the
// system content margins is shown.
let mediumRows = 3
let smallRows = 2

/// mindful_medium_widget.xml: routines and today's tasks side by side, each
/// with a label + accent count; the Todo column (and divider) hidden when
/// nothing is due, so routines fill the width. Pencil → write sheet.
struct MediumWidgetView: View {
  let data: WidgetSnapshot

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      ListColumn(
        title: data.labels.routines,
        count: data.labels.doneCount(data.routinesDone, of: data.routines.count),
        accent: WidgetColors.habit
      ) {
        ForEach(data.routines.prefix(mediumRows)) {
          RoutineRow(routine: $0, maxPills: data.tasksTotal > 0 ? 1 : 2, linksToDetail: true)
        }
      }
      if data.tasksTotal > 0 {
        Rectangle()
          .fill(WidgetColors.divider)
          .frame(width: 0.5)
          .padding(.vertical, 4)
        ListColumn(
          title: data.labels.tasks,
          count: data.labels.doneCount(data.tasksDone, of: data.tasksTotal),
          accent: WidgetColors.task
        ) {
          ForEach(data.tasks.prefix(mediumRows)) { TaskRow(task: $0, linksToDetail: true) }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .overlay(alignment: .bottomTrailing) { PencilButton() }
  }
}

/// One medium-widget column: "Routines 2/4 done" header + its rows.
struct ListColumn<Rows: View>: View {
  let title: String
  let count: String
  let accent: Color
  @ViewBuilder let rows: Rows

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 6) {
        Text(title).foregroundStyle(WidgetColors.textSecondary)
        Text(count).foregroundStyle(accent)
      }
      .font(.system(size: 12))
      .lineLimit(1)
      rows
    }
    .frame(maxWidth: .infinity, alignment: .topLeading)
  }
}

/// widget_pencil_background.xml + ic_widget_pencil → `open-write-sheet`.
struct PencilButton: View {
  var body: some View {
    Link(destination: widgetLink("open-write-sheet")) {
      Image(systemName: "pencil")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(WidgetColors.pencil)
        .frame(width: 20, height: 20)
        .padding(10)
        .background(
          Circle()
            .fill(WidgetColors.buttonBackground)
            .strokeBorder(WidgetColors.buttonBorder, lineWidth: 0.5))
    }
  }
}

// MARK: - Small (2x2): chooser, then Todo or Routines

/// mindful_small_widget(_choose).xml. The pick is shared by every small
/// widget, like Android's `smallWidgetMode`.
struct SmallWidgetView: View {
  let data: WidgetSnapshot

  var body: some View {
    switch data.smallMode {
    case nil: SmallChooserView(labels: data.labels)
    case .tasks?: SmallListView(data: data, isTasks: true)
    case .habits?: SmallListView(data: data, isTasks: false)
    }
  }
}

struct SmallChooserView: View {
  let labels: WidgetLabels

  var body: some View {
    VStack(spacing: 8) {
      Text(labels.showMe)
        .font(.system(size: 14))
        .foregroundStyle(WidgetColors.textPrimary)
      // Side by side like Android when the labels fit, else stacked.
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 8) { choices }
        VStack(spacing: 8) { choices }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder private var choices: some View {
    choice(labels.chooseTasks, "checklist", .tasks)
    choice(labels.chooseRoutines, "figure.mind.and.body", .habits)
  }

  private func choice(_ title: String, _ symbol: String, _ mode: SmallWidgetMode)
    -> some View
  {
    Button(intent: ChooseSmallWidgetModeIntent(mode: mode)) {
      Label(title, systemImage: symbol)
        .font(.system(size: 12))
        .foregroundStyle(WidgetColors.textPrimary)
        .lineLimit(1)
        .fixedSize()
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(WidgetColors.buttonBackground)
            .strokeBorder(WidgetColors.buttonBorder, lineWidth: 0.5))
    }
    .buttonStyle(.plain)
  }
}

/// Bold title + accent "done/total", the list, "N remaining" footer.
struct SmallListView: View {
  let data: WidgetSnapshot
  let isTasks: Bool

  private var done: Int { isTasks ? data.tasksDone : data.routinesDone }
  private var total: Int { isTasks ? data.tasksTotal : data.routines.count }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(isTasks ? data.labels.tasks : data.labels.routines)
          .foregroundStyle(WidgetColors.textPrimary)
        Spacer(minLength: 0)
        Text("\(done)/\(total)")
          .foregroundStyle(isTasks ? WidgetColors.task : WidgetColors.habit)
      }
      .font(.system(size: 13, weight: .bold))
      .padding(.bottom, 6)
      if isTasks {
        ForEach(data.tasks.prefix(smallRows)) { TaskRow(task: $0) }
      } else {
        ForEach(data.routines.prefix(smallRows)) { RoutineRow(routine: $0, maxPills: 1) }
      }
      Spacer(minLength: 0)
      Text(data.labels.remaining(total - done))
        .font(.system(size: 11))
        .foregroundStyle(WidgetColors.textFooter)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    // Small widgets only route widgetURL, not per-row Links.
    .widgetURL(widgetLink(isTasks ? "home/tasks" : "home/habits"))
  }
}

// MARK: - Widgets

struct MindfulMediumWidget: Widget {
  /// Must match `WidgetProviderNames.iOSMediumWidget`.
  let kind: String = "MindfulMediumWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfulProvider()) { entry in
      MediumWidgetView(data: entry.data)
        .containerBackground(for: .widget) { GlassWidgetBackground() }
    }
    .configurationDisplayName("Mindful")
    .description("Today's routines and todos.")
    .supportedFamilies([.systemMedium])
  }
}

struct MindfulSmallWidget: Widget {
  /// Must match `WidgetProviderNames.iOSSmallWidget`.
  let kind: String = "MindfulSmallWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfulProvider()) { entry in
      SmallWidgetView(data: entry.data)
        .containerBackground(for: .widget) { GlassWidgetBackground() }
    }
    .configurationDisplayName("Mindful")
    .description("Today's todos or routines.")
    .supportedFamilies([.systemSmall])
  }
}

// MARK: - Lock screen (circular count)

struct MindfulLockScreenWidgetView: View {
  let data: WidgetSnapshot

  var body: some View {
    Gauge(
      value: Double(data.routinesDone),
      in: 0...Double(max(data.routines.count, 1))
    ) {
      Text(data.labels.routines)
    } currentValueLabel: {
      Text("\(data.routinesDone)/\(data.routines.count)")
    }
    .gaugeStyle(.accessoryCircular)
    .widgetURL(widgetLink("home/habits"))
    .containerBackground(for: .widget) { AccessoryWidgetBackground() }
  }
}

struct MindfulLockScreenWidget: Widget {
  /// Must match `WidgetProviderNames.iOSLockScreenWidget`.
  let kind: String = "MindfulLockScreenWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfulProvider()) { entry in
      MindfulLockScreenWidgetView(data: entry.data)
    }
    .configurationDisplayName("Mindful Routine Count")
    .description("How many of today's routines are done.")
    .supportedFamilies([.accessoryCircular])
  }
}

// MARK: - Bundle

@main
struct MindfulWidgets: WidgetBundle {
  var body: some Widget {
    MindfulMediumWidget()
    MindfulSmallWidget()
    MindfulLockScreenWidget()
    MindfulRoutineLockScreenWidget()
  }
}

#Preview(as: .systemMedium) {
  MindfulMediumWidget()
} timeline: {
  MindfulEntry.placeholder
}

#Preview(as: .systemSmall) {
  MindfulSmallWidget()
} timeline: {
  MindfulEntry.placeholder
}
