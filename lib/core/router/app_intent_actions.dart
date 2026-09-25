import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'sheet_navigation.dart';

/// The channel `AppActionBridge` (ios/Runner/AppDelegate.swift) sends App
/// Intent actions over.
const MethodChannel appActionsChannel = MethodChannel('mindful/app_actions');

/// Handles iOS App Intents — today just "Add spending", which the user can
/// run from Shortcuts, Siri, or bind to a Back Tap in Settings >
/// Accessibility > Touch > Back Tap. See SPEC.md App Intents.
///
/// Picks up an action that launched the app (collected with
/// `takePendingAction`) as well as ones arriving while it's running. No-op
/// off iOS.
void listenForAppIntentActions(GoRouter router) {
  if (defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  appActionsChannel.setMethodCallHandler((call) async {
    if (call.method == 'action') {
      handleAppIntentAction(router, call.arguments as String?);
    }
  });
  unawaited(
    appActionsChannel
        .invokeMethod<String>('takePendingAction')
        .then((action) => handleAppIntentAction(router, action))
        .catchError((Object error) {
          debugPrint('App intent channel unavailable: $error');
        }),
  );
}

/// Opens whatever [action] asks for, once the app is on a `/home` tab.
///
/// A cold start from Back Tap lands on the splash screen (and maybe login)
/// first — a sheet opened there would be torn down by the redirect to
/// home, so it waits for that instead.
void handleAppIntentAction(GoRouter router, String? action) {
  final open = switch (action) {
    'addSpending' => () => openAddMoneySheet(router),
    _ => null,
  };
  if (open == null) {
    return;
  }
  runWhenOnHome(router, open);
}

/// Runs [open] now if [router] is on a `/home` tab, else the first time it
/// gets there (a frame later, so the tab has built).
@visibleForTesting
void runWhenOnHome(GoRouter router, VoidCallback open) {
  final delegate = router.routerDelegate;
  bool onHome() => delegate.currentConfiguration.uri.path.startsWith('/home');

  if (onHome()) {
    open();
    return;
  }
  late final VoidCallback listener;
  listener = () {
    if (!onHome()) {
      return;
    }
    delegate.removeListener(listener);
    // Give the home route a frame to build before showing a sheet over it.
    WidgetsBinding.instance.addPostFrameCallback((_) => open());
  };
  delegate.addListener(listener);
}
