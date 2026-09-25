import AppIntents
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "MindfullAppActions") {
      AppActionBridge.shared.attach(to: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Hands actions triggered from outside the app (App Intents — Shortcuts,
/// Siri, Back Tap) to Dart over the `mindfull/app_actions` channel.
///
/// An intent can fire before Dart has registered its handler (a cold start
/// from Back Tap is the common case), so the action is kept as pending
/// until Dart either handles the live call or collects it with
/// `takePendingAction` once it's ready.
final class AppActionBridge {
  static let shared = AppActionBridge()

  private var channel: FlutterMethodChannel?
  private var pendingAction: String?

  func attach(to messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "mindfull/app_actions",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "takePendingAction" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.pendingAction)
      self?.pendingAction = nil
    }
    self.channel = channel
  }

  func send(_ action: String) {
    pendingAction = action
    channel?.invokeMethod("action", arguments: action) { [weak self] response in
      // No Dart handler yet — leave it pending for takePendingAction.
      if (response as AnyObject?) !== FlutterMethodNotImplemented {
        self?.pendingAction = nil
      }
    }
  }
}

/// "Add spending" — opens the app on the Add Money sheet with Spending
/// selected. Exposed to Shortcuts (and so to Settings > Accessibility >
/// Touch > Back Tap) through [MindfullShortcuts].
@available(iOS 16.0, *)
struct AddSpendingIntent: AppIntent {
  static var title: LocalizedStringResource = "Add spending"
  static var description = IntentDescription("Opens Mindfull to log a new spending entry.")
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult {
    AppActionBridge.shared.send("addSpending")
    return .result()
  }
}

/// Registers the app's intents as App Shortcuts, so they show up in the
/// Shortcuts app with no setup by the user.
@available(iOS 16.0, *)
struct MindfullShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: AddSpendingIntent(),
      phrases: [
        "Add spending in \(.applicationName)",
        "Log spending in \(.applicationName)",
      ],
      shortTitle: "Add spending",
      systemImageName: "creditcard"
    )
  }
}
