//
//  MindfulWidgets.swift
//  MindfulWidgets
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

private let appGroupId = "group.com.guswira.mindful.widget"

// MARK: - Entry

struct MindfulTask: Identifiable {
  let id: String
  let name: String
}

struct MindfulEntry: TimelineEntry {
  let date: Date
  let dateLabel: String
  let journalStreak: Int
  let habitsCompleted: Int
  let habitsTotal: Int
  let tasks: [MindfulTask]
  /// Pushed by widget_service.dart in the app's language.
  var habitsLabel: String = "Habits"
  var habitsCountLabel: String? = nil

  static let placeholder = MindfulEntry(
    date: Date(),
    dateLabel: "Sep 21",
    journalStreak: 3,
    habitsCompleted: 2,
    habitsTotal: 4,
    tasks: [
      MindfulTask(id: "1", name: "Buy groceries"),
      MindfulTask(id: "2", name: "Renew passport"),
    ]
  )
}

// MARK: - Provider

struct MindfulProvider: TimelineProvider {
  func placeholder(in context: Context) -> MindfulEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (MindfulEntry) -> Void) {
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<MindfulEntry>) -> Void) {
    // Data only changes when the app calls `widget_service.dart`'s
    // updateWidget(), which reloads this timeline directly — no periodic
    // refresh needed in between.
    completion(Timeline(entries: [currentEntry()], policy: .never))
  }

  private func currentEntry() -> MindfulEntry {
    let data = UserDefaults(suiteName: appGroupId)
    let tasks = [
      ("task1Id", "task1Name"), ("task2Id", "task2Name"), ("task3Id", "task3Name"),
    ].compactMap { idKey, nameKey -> MindfulTask? in
      guard let id = data?.string(forKey: idKey), let name = data?.string(forKey: nameKey) else {
        return nil
      }
      return MindfulTask(id: id, name: name)
    }

    return MindfulEntry(
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

struct MindfulHomeWidgetView: View {
  @Environment(\.widgetFamily) private var family
  var entry: MindfulEntry

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
          // to the whole-widget `.widgetURL(mindful://home)` below on
          // iOS versions that don't route per-view Links from widgets.
          Link(destination: URL(string: "mindful://tasks/\(task.id)")!) {
            Text(task.name)
              .font(.caption)
              .lineLimit(1)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding()
    .widgetURL(URL(string: "mindful://home"))
  }
}

struct MindfulHomeWidget: Widget {
  let kind: String = "MindfulHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfulProvider()) { entry in
      MindfulHomeWidgetView(entry: entry)
    }
    .configurationDisplayName("Mindful")
    .description("Today's date, journal streak, habit progress and tasks.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - Lock screen widget (circular)

struct MindfulLockScreenWidgetView: View {
  var entry: MindfulEntry

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
    .widgetURL(URL(string: "mindful://home"))
  }
}

struct MindfulLockScreenWidget: Widget {
  let kind: String = "MindfulLockScreenWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MindfulProvider()) { entry in
      MindfulLockScreenWidgetView(entry: entry)
    }
    .configurationDisplayName("Mindful Habits")
    .description("Today's habit completion count.")
    .supportedFamilies([.accessoryCircular])
  }
}

// MARK: - Bundle

@main
struct MindfulWidgets: WidgetBundle {
  var body: some Widget {
    MindfulHomeWidget()
    MindfulLockScreenWidget()
  }
}

// MARK: - Previews

struct MindfulWidgets_Previews: PreviewProvider {
  static var previews: some View {
    MindfulHomeWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    MindfulHomeWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .systemMedium))
    MindfulLockScreenWidgetView(entry: .placeholder)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
