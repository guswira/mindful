import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quick_actions/quick_actions.dart';

import 'app.dart';
import 'core/l10n/app_language.dart';
import 'core/l10n/app_language_controller.dart';
import 'core/l10n/l10n.dart';
import 'core/router/app_intent_actions.dart';
import 'core/router/router.dart';
import 'features/habits/data/habit_reminders_controller.dart';
import 'features/settings/data/journal_reminders_controller.dart';
import 'features/tasks/data/task_reminders_controller.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/supabase_service.dart';
import 'shared/services/widget_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await const SupabaseService().initialize();
  await Hive.initFlutter();
  // Date symbols for every supported locale, so DateFormat works in
  // Bahasa even outside a widget (notifications, the home widget).
  await initializeDateFormatting();

  // Built here, rather than left for MaterialApp.router's own
  // ProviderScope to create, so the quick_actions callback below can push
  // to the exact GoRouter instance the running app uses.
  final container = ProviderContainer();
  await container.read(appLanguageControllerProvider.notifier).restore();
  _applyLanguage(container.read(appLanguageControllerProvider));
  final router = container.read(appRouterProvider);

  const quickActions = QuickActions();
  // Also fires immediately with the launching shortcut's type when the app
  // is cold-started from one, same as a tap while already running. Each
  // shortcut opens its add sheet directly — none of these are routes any
  // more, per the bottom-sheet design rules.
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
  // iOS App Intents ("Add spending") — for Shortcuts, Siri and Back Tap.
  listenForAppIntentActions(router);

  // Copy baked into things outside the widget tree — shortcut titles and
  // already-scheduled notifications — would otherwise stay in the old
  // language until the next app start.
  container.listen(appLanguageControllerProvider, (_, language) async {
    _applyLanguage(language);
    await _setShortcutItems(quickActions);
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

  runApp(UncontrolledProviderScope(container: container, child: const App()));
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
