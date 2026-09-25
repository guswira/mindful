//
//  MindfullWidgets.swift
//  MindfullWidgets
//
//  Home screen (small/medium) and lock screen widgets. Data is written by
//  `widget_service.dart` via `home_widget`'s shared App Group container.
//  See SPEC.md Home and Lock Screen Widgets.
//
//  This file alone is not a working Xcode target — see the "Manual Xcode
//  setup" note in the phase summary for the steps still needed to wire it
//  into a Widget Extension target.
//

import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.mindfull.widget"

// MARK: - Entry

struct MindfullTask: Identifiable {
  let id: String
  let name: String
}

struct MindfullEntry: TimelineEntry {
  let date: Date
  let dateLabel: String
  let journalStreak: Int
  let habitsCompleted: Int
  let habitsTotal: Int
  let tasks: [MindfullTask]
  /// Pushed by widget_service.dart in the app's language.
  var habitsLabel: String = "Habits"
  var habitsCountLabel: String? = nil

  static let placeholder = MindfullEntry(
    date: Date(),
    dateLabel: "Sep 21",
    journalStreak: 3,
    habitsCompleted: 2,
    habitsTotal: 4,
    tasks: [
      MindfullTask(id: "1", name: "Buy groceries"),
      MindfullTask(id: "2", name: "Renew passport"),
    ]
  )
}

// MARK: - Provider

struct MindfullProvider: TimelineProvider {
  func placeholder(in context: Context) -> MindfullEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (MindfullEntry) -> Void) {
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<MindfullEntry>) -> Void) {
    // Data only changes when the app calls `widget_service.dart`'s
    // updateWidget(), which reloads this timeline directly — no periodic
    // refresh needed in between.
    completion(Timeline(entries: [currentEntry()], policy: .never))
  }

  private func currentEntry() -> MindfullEntry {
    let data = UserDefaults(suiteName: appGroupId)
    let tasks = [
      ("task1Id", "task1Name"), ("task2Id", "task2Name"), ("task3Id", "task3Name"),
    ].compactMap { idKey, nameKey -> MindfullTask? in
      guard let id = data?.string(forKey: idKey), let name = data?.string(forKey: nameKey) else {
        return nil
      }
      return MindfullTask(id: id, name: name)
    }

    return MindfullEntry(
      date: Date(),
      dateLabel: data?.string(forKey: "date") ?? "--",
      journalStreak: data?.integer(forKey: "journalStreak") ?? 0,
      habitsCompleted: data?.integer(forKey: "habitsCompleted") ?? 0,
      habitsTotal: data?.integer(forKey: "habitsTotal") ?? 0,
      tasks: tasks,
      habitsLabel: data?.string(forKey: "labelHabits") ?? "Habits",
      habitsCountLabel: data?.string(forKey: "labelHabitsCount")
    )
  }
}

// MARK: - Home widget (small + medium)

struct MindfullHomeWidgetView: View {
  @Environment(\.widgetFamily) private var family
  var entry: MindfullEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(entry.dateLabel).font(.headline)
      Text("🔥 \(entry.journalStreak)").font(.subheadline)
      Text(entry.habitsCountLabel ?? "\(entry.habitsCompleted)/\(entry.habitsTotal) done")
        .font(.subheadline)

      if family == .systemMedium, !entry.tasks.isEmpty {
        Divider()
        ForEach(entry.tasks) { task in
          // Per-row deep link to that task's detail screen — falls back
          // to the whole-widget `.widgetURL(mindfull://home)` below on
          // iOS versions that don't route per-view Links from widgets.
          Link(destination: URL(string: "mindfull://tasks/\(task.id)")!) {
            Text(task.name)
              .font(.caption)
              .lineLimit(1)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding()
    .widgetURL(URL(string: "mindfull://home"))
  }
}

struct MindfullHomeWidget: Widget {
  let kind: String = "MindfullHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfullProvider()) { entry in
      MindfullHomeWidgetView(entry: entry)
    }
    .configurationDisplayName("Mindfull")
    .description("Today's date, journal streak, habit progress and tasks.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Lock screen widget (circular)

struct MindfullLockScreenWidgetView: View {
  var entry: MindfullEntry

  var body: some View {
    Gauge(
      value: Double(entry.habitsCompleted),
      in: 0...Double(max(entry.habitsTotal, 1))
    ) {
      Text(entry.habitsLabel)
    } currentValueLabel: {
      Text("\(entry.habitsCompleted)/\(entry.habitsTotal)")
    }
    .gaugeStyle(.accessoryCircular)
    .widgetURL(URL(string: "mindfull://home"))
  }
}

struct MindfullLockScreenWidget: Widget {
  let kind: String = "MindfullLockScreenWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfullProvider()) { entry in
      MindfullLockScreenWidgetView(entry: entry)
    }
    .configurationDisplayName("Mindfull Habits")
    .description("Today's habit completion count.")
    .supportedFamilies([.accessoryCircular])
  }
}

// MARK: - Bundle

@main
struct MindfullWidgets: WidgetBundle {
  var body: some Widget {
    MindfullHomeWidget()
    MindfullLockScreenWidget()
  }
}

// MARK: - Previews

struct MindfullWidgets_Previews: PreviewProvider {
  static var previews: some View {
    MindfullHomeWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    MindfullHomeWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    MindfullLockScreenWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
