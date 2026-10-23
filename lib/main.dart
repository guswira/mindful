import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:quick_actions/quick_actions.dart';

import 'app.dart';
import 'core/l10n/app_language.dart';
import 'core/l10n/app_language_controller.dart';
import 'core/l10n/date_symbols_subset.dart';
import 'core/l10n/l10n.dart';
import 'core/platform/platform_features.dart';
import 'core/router/app_intent_actions.dart';
import 'core/router/router.dart';
import 'core/theme/glass_style.dart';
import 'core/theme/glass_style_controller.dart';
import 'features/habits/data/habit_reminders_controller.dart';
import 'features/habits/presentation/widget_habit_log_sync.dart';
import 'features/settings/data/journal_reminders_controller.dart';
import 'features/tasks/data/task_reminders_controller.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/supabase_service.dart';
import 'shared/services/widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Web: /home/today rather than /#/home/today (no-op elsewhere). The host
  // rewrites every path to index.html — see web/_redirects.
  usePathUrlStrategy();
  // Independent of each other, so they run side by side — the first
  // frame waits for the slowest one, not their sum (it's most noticeable
  // on web, where every step is a fetch or an IndexedDB/WebCrypto call).
  await Future.wait([_initializeSupabase(), Hive.initFlutter()]);
  // Date symbols for the app's languages, so DateFormat works in Bahasa
  // even outside a widget (notifications, the home widget). Synchronous —
  // the data is bundled.
  initializeAppDateFormatting();
  // Before anything touches home_widget — building the router below asks
  // it for the launching widget URL, which throws on iOS without a group.
  if (isNativeIOS) {
    await HomeWidget.setAppGroupId(WidgetProviderNames.iOSAppGroupId);
  }

  // Built here, rather than left for MaterialApp.router's own
  // ProviderScope to create, so the quick_actions callback below can push
  // to the exact GoRouter instance the running app uses.
  final container = ProviderContainer();
  await Future.wait([
    container.read(appLanguageControllerProvider.notifier).restore(),
    container.read(glassStyleControllerProvider.notifier).restore(),
  ]);
  _applyLanguage(container.read(appLanguageControllerProvider));
  // Loads the liquid glass shaders (disk → RAM only, no GPU work) before
  // the first frame, so the tab bar and cards don't flash unglazed. Only
  // in liquid style: frosted (the web default) never draws them, and
  // switching to liquid in Settings loads them then
  // (GlassStyleController.select).
  if (container.read(glassStyleControllerProvider) == GlassStyle.liquid) {
    await lg.LiquidGlassWidgets.initialize();
  }
  final router = container.read(appRouterProvider);

  const quickActions = QuickActions();
  // Also fires immediately with the launching shortcut's type when the app
  // is cold-started from one, same as a tap while already running. Each
  // shortcut opens its add sheet directly — none of these are routes any
  // more, per the bottom-sheet design rules. Phones only — quick_actions
  // has no desktop/web implementation.
  if (isPhonePlatform) {
    await quickActions.initialize((type) {
      switch (type) {
        case 'newJournal':
          openAddJournalSheet(router);
        case 'newTask':
          openAddTaskSheet(router);
        case 'newHabit':
          openAddHabitSheet(router);
        case 'newMoney':
          openAddMoneySheet(router);
        case 'scanFood':
          router.go('/home/ai');
      }
    });
    await _setShortcutItems(quickActions);
  }
  // iOS App Intents ("Add spending") — for Shortcuts, Siri and Back Tap.
  listenForAppIntentActions(router);
  if (isNativeIOS) {
    // Routine taps on the iOS lock screen widget, queued while closed.
    listenForWidgetHabitLogs(container);
  }

  // Copy baked into things outside the widget tree — shortcut titles and
  // already-scheduled notifications — would otherwise stay in the old
  // language until the next app start.
  container.listen(appLanguageControllerProvider, (_, language) async {
    _applyLanguage(language);
    if (isPhonePlatform) {
      await _setShortcutItems(quickActions);
    }
    container
      ..refresh(journalRemindersProvider)
      ..refresh(taskRemindersProvider)
      ..refresh(habitRemindersProvider);
    final notifications = await container.read(
      notificationServiceProvider.future,
    );
    await notifications.scheduleBudgetResetReminder();
    await refreshWidgetsBestEffort(
      () => container.read(widgetServiceProvider.future),
    );
  });

  runApp(
    lg.LiquidGlassWidgets.wrap(
      // MaterialApp: glass follows its (always dark) theme, not the OS.
      brightnessResolver: Theme.maybeBrightnessOf,
      // Benchmarks the device and steps glass quality down on slow or
      // throttling hardware (budget Android) instead of dropping frames.
      adaptiveQuality: true,
      child: UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    ),
  );
}

/// Supabase needs `.env`'s URL and key, so it waits for that load — but
/// nothing else in main() has to wait for either.
Future<void> _initializeSupabase() async {
  await dotenv.load();
  await const SupabaseService().initialize();
}

/// Points [currentL10n] at [language] (or the device's language) ahead of
/// MaterialApp's own locale resolution, for code that runs before it.
void _applyLanguage(AppLanguage language) => setCurrentAppLocale(
  language.locale ?? WidgetsBinding.instance.platformDispatcher.locale,
);

Future<void> _setShortcutItems(QuickActions quickActions) {
  final l10n = currentL10n;
  return quickActions.setShortcutItems([
    ShortcutItem(
      type: 'newJournal',
      localizedTitle: l10n.shortcutNewJournal,
      icon: 'journal',
    ),
    ShortcutItem(
      type: 'newTask',
      localizedTitle: l10n.shortcutNewTask,
      icon: 'task',
    ),
    ShortcutItem(
      type: 'newHabit',
      localizedTitle: l10n.shortcutNewHabit,
      icon: 'habit',
    ),
    ShortcutItem(
      type: 'newMoney',
      localizedTitle: l10n.shortcutAddMoney,
      icon: 'money',
    ),
    ShortcutItem(
      type: 'scanFood',
      localizedTitle: l10n.shortcutScanFood,
      icon: 'ic_camera',
    ),
  ]);
}
