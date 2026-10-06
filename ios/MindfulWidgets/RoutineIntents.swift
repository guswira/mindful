//
//  RoutineIntents.swift
//  MindfulWidgets
//
//  Interactive (iOS 17) intents behind the routine lock screen widget's
//  buttons, and its "which routine" configuration. They run in the widget
//  extension without opening the app — see RoutineStore for how the app
//  catches up. See SPEC.md Home and Lock Screen Widgets.
//

import AppIntents
import WidgetKit

/// Checks a routine for today, via one of its actions or plain "done".
struct LogRoutineIntent: AppIntent {
  static let title: LocalizedStringResource = "Check routine"
  static let isDiscoverable = false

  @Parameter(title: "Routine ID") var habitId: String
  @Parameter(title: "Action") var actionLabel: String?

  init() {}

  init(habitId: String, actionLabel: String?) {
    self.habitId = habitId
    self.actionLabel = actionLabel
  }

  func perform() async throws -> some IntentResult {
    RoutineStore.log(habitId: habitId, actionLabel: actionLabel)
    // The tapped widget reloads on its own; this also redraws the home
    // screen widget's routine count.
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

/// Unchecks a routine for today — tapping its check or selected action
/// again, like the in-app routine rows.
struct UnlogRoutineIntent: AppIntent {
  static let title: LocalizedStringResource = "Uncheck routine"
  static let isDiscoverable = false

  @Parameter(title: "Routine ID") var habitId: String

  init() {}

  init(habitId: String) {
    self.habitId = habitId
  }

  func perform() async throws -> some IntentResult {
    RoutineStore.unlog(habitId: habitId)
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

/// A routine offered in the widget's "Edit Widget" picker.
struct RoutineEntity: AppEntity {
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Routine"
  static let defaultQuery = RoutineEntityQuery()

  let id: String
  let name: String
  let icon: String

  init(_ routine: WidgetRoutine) {
    id = routine.id
    name = routine.name
    icon = routine.icon
  }

  var displayRepresentation: DisplayRepresentation {
    if let symbol = routineSymbol(for: icon) {
      DisplayRepresentation(title: "\(name)", image: .init(systemName: symbol))
    } else {
      DisplayRepresentation(title: "\(icon) \(name)")
    }
  }
}

struct RoutineEntityQuery: EntityQuery {
  func entities(for identifiers: [RoutineEntity.ID]) async throws -> [RoutineEntity] {
    RoutineStore.routines().filter { identifiers.contains($0.id) }.map(RoutineEntity.init)
  }

  func suggestedEntities() async throws -> [RoutineEntity] {
    RoutineStore.routines().map(RoutineEntity.init)
  }
}

/// Long-press → Edit Widget. No routine picked = list today's routines.
struct SelectRoutineIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Routine"
  static let description = IntentDescription(
    "Pick one routine to check off or choose its action, or leave empty to list today's routines."
  )

  @Parameter(title: "Routine") var routine: RoutineEntity?

  init() {}
}

/// The small widget chooser's "Todo" / "Routines" buttons.
struct ChooseSmallWidgetModeIntent: AppIntent {
  static let title: LocalizedStringResource = "Choose widget list"
  static let isDiscoverable = false

  @Parameter(title: "List") var mode: String

  init() {}

  init(mode: SmallWidgetMode) {
    self.mode = mode.rawValue
  }

  func perform() async throws -> some IntentResult {
    if let mode = SmallWidgetMode(rawValue: mode) {
      RoutineStore.setSmallMode(mode)
    }
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}
