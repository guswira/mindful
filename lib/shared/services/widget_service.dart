import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/habits/data/habit_repository.dart';
import '../../features/habits/domain/habit.dart';
import '../../features/habits/domain/habit_log.dart';
import '../../features/journal/data/journal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../features/tasks/data/task_repository.dart';

part 'widget_service.g.dart';

/// Native widget identifiers. See SPEC.md Home and Lock Screen Widgets.
class WidgetProviderNames {
  const WidgetProviderNames._();

  // `home_widget` resolves Android widgets by fully-qualified class name
  // only (no relative-package form), so this must stay in sync with
  // android/app/build.gradle.kts's applicationId and the `package`
  // declared in the widgets/ provider classes.
  static const String _androidPackage = 'com.example.mindfull.widgets';
  static const String mediumAndroidQualified =
      '$_androidPackage.MindfullMediumWidget';
  static const String smallAndroidQualified =
      '$_androidPackage.MindfullSmallWidget';

  // iOS widgets are looked up by the `kind` given to their WidgetKit
  // `StaticConfiguration`/`AppIntentConfiguration`, not a class name.
  static const String iOSMediumWidget = 'MindfullMediumWidget';
  static const String iOSSmallWidget = 'MindfullSmallWidget';
  static const String iOSLockScreenWidget = 'MindfullLockScreen';
}

/// Collects today's home/lock screen widget data and pushes it to the
/// native side via `home_widget`. See SPEC.md Home and Lock Screen
/// Widgets.
class WidgetService {
  WidgetService({
    required JournalRepository journalRepository,
    required HabitRepository habitRepository,
    required TaskRepository taskRepository,
    DateTime Function() now = DateTime.now,
  }) : _journalRepository = journalRepository,
       _habitRepository = habitRepository,
       _taskRepository = taskRepository,
       _now = now;

  final JournalRepository _journalRepository;
  final HabitRepository _habitRepository;
  final TaskRepository _taskRepository;
  final DateTime Function() _now;

  /// Recomputes today's widget data from the local cache and asks the
  /// native widgets to redraw. Called on app open and after any journal,
  /// habit or task write — see SPEC.md.
  Future<void> updateWidgetData() async {
    final today = _dateOnly(_now());

    final habits = _habitRepository.getTodayHabits();
    final logs = _habitRepository.getTodayLogs();
    final tasks = _taskRepository.getDueToday();
    final logsByHabitId = {for (final log in logs) log.habitId: log};

    final habitsDone = logs.length;
    final habitsTotal = habits.length;
    final tasksDone = tasks.where((task) => task.isCompleted).length;
    final tasksTotal = tasks.length;

    final habitsJson = jsonEncode([
      for (final habit in habits) _habitJson(habit, logsByHabitId[habit.id]),
    ]);
    final tasksJson = jsonEncode([
      for (final task in tasks)
        {'id': task.id, 'name': task.name, 'isCompleted': task.isCompleted},
    ]);

    await Future.wait([
      HomeWidget.saveWidgetData<String>('habits', habitsJson),
      HomeWidget.saveWidgetData<String>('tasks', tasksJson),
      HomeWidget.saveWidgetData<int>('habitsDone', habitsDone),
      HomeWidget.saveWidgetData<int>('habitsTotal', habitsTotal),
      HomeWidget.saveWidgetData<int>('tasksDone', tasksDone),
      HomeWidget.saveWidgetData<int>('tasksTotal', tasksTotal),
      HomeWidget.saveWidgetData<int>('journalStreak', _journalStreak(today)),
      HomeWidget.saveWidgetData<String>(
        'date',
        DateFormat('EEEE, MMM d').format(_now()),
      ),
      HomeWidget.saveWidgetData<String>(
        'smallWidgetMode',
        await _getSmallWidgetMode(),
      ),
      ..._saveLabels(
        habitsDone: habitsDone,
        habitsTotal: habitsTotal,
        tasksDone: tasksDone,
        tasksTotal: tasksTotal,
      ),
    ]);

    // Each platform's `home_widget` plugin errors if asked to update a
    // widget it doesn't recognize (an Android class name on iOS, or a
    // missing `ios` name on Android), so only the matching platform's
    // widgets are asked to redraw.
    if (Platform.isAndroid) {
      await HomeWidget.updateWidget(
        qualifiedAndroidName: WidgetProviderNames.mediumAndroidQualified,
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: WidgetProviderNames.smallAndroidQualified,
      );
    } else if (Platform.isIOS) {
      await HomeWidget.updateWidget(
        iOSName: WidgetProviderNames.iOSMediumWidget,
      );
      await HomeWidget.updateWidget(
        iOSName: WidgetProviderNames.iOSSmallWidget,
      );
    }
  }

  /// Native widgets can't read the ARB files, so their copy is pushed in
  /// the app's current language — which may differ from the device's.
  /// Native code falls back to English if a label is missing.
  List<Future<bool?>> _saveLabels({
    required int habitsDone,
    required int habitsTotal,
    required int tasksDone,
    required int tasksTotal,
  }) {
    final l10n = currentL10n;
    return [
      for (final (key, value) in [
        ('labelTasks', l10n.widgetLabelTasks),
        ('labelHabits', l10n.widgetLabelHabits),
        ('labelShowMe', l10n.widgetLabelShowMe),
        ('labelChooseTasks', l10n.widgetChooseTasks),
        ('labelChooseHabits', l10n.widgetChooseHabits),
        ('labelHabitsCount', l10n.widgetDoneCount(habitsDone, habitsTotal)),
        ('labelTasksCount', l10n.widgetDoneCount(tasksDone, tasksTotal)),
        ('labelHabitsRemaining', l10n.widgetRemaining(habitsTotal - habitsDone)),
        ('labelTasksRemaining', l10n.widgetRemaining(tasksTotal - tasksDone)),
      ])
        HomeWidget.saveWidgetData<String>(key, value),
    ];
  }

  Map<String, dynamic> _habitJson(Habit habit, HabitLog? todayLog) => {
    'id': habit.id,
    'name': habit.name,
    'icon': habit.icon,
    'color': habit.color,
    'actions': [for (final action in habit.actions) action.label],
    'isCompleted': todayLog != null,
    'completedAction': todayLog?.completedActionId,
  };

  /// The small widget's chosen list ('tasks' or 'habits'), defaulting to
  /// 'tasks' until the user picks one from its chooser.
  Future<String> _getSmallWidgetMode() async {
    final mode = await HomeWidget.getWidgetData<String>('smallWidgetMode');
    return mode == 'habits' ? 'habits' : 'tasks';
  }

  /// Saves the small widget's chosen list and immediately redraws it.
  Future<void> saveSmallWidgetMode(String mode) async {
    await HomeWidget.saveWidgetData<String>('smallWidgetMode', mode);
    await updateWidgetData();
  }

  /// Consecutive days up to and including [today] with at least one
  /// journal entry.
  int _journalStreak(DateTime today) {
    final entryDates = {
      for (final entry in _journalRepository.getAll()) _dateOnly(entry.date),
    };
    var streak = 0;
    var cursor = today;
    while (entryDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// The app-wide [WidgetService], backed by the journal/habit/task
/// repositories.
@Riverpod(keepAlive: true)
Future<WidgetService> widgetService(Ref ref) async {
  final journalRepository = await ref.watch(journalRepositoryProvider.future);
  final habitRepository = await ref.watch(habitRepositoryProvider.future);
  final taskRepository = await ref.watch(taskRepositoryProvider.future);
  return WidgetService(
    journalRepository: journalRepository,
    habitRepository: habitRepository,
    taskRepository: taskRepository,
  );
}

/// Refreshes the home/lock screen widgets, swallowing any failure (e.g. no
/// widget pinned yet) — the write that triggered this call should still
/// count as successful either way. Shared by every write path that must
/// keep the widgets current: [WidgetService.updateWidgetData] callers
/// listed in SPEC.md Home and Lock Screen Widgets.
///
/// Takes `() => ref.read(widgetServiceProvider.future)` rather than a
/// `Ref`/`WidgetRef` itself, so it works the same from a [Notifier] and
/// from a `ConsumerState`.
Future<void> refreshWidgetsBestEffort(
  Future<WidgetService> Function() readWidgetService,
) async {
  try {
    final widgetService = await readWidgetService();
    await widgetService.updateWidgetData();
  } catch (error) {
    // Best-effort — see doc comment.
    debugPrint('Widget refresh failed: $error');
  }
}
