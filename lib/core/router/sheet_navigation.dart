import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/habits/data/habit_repository.dart';
import '../../features/habits/domain/habit.dart';
import '../../features/habits/domain/habit_action.dart';
import '../../features/habits/presentation/add_habit_sheet.dart';
import '../../features/habits/presentation/habit_tab.dart';
import '../../features/journal/presentation/add_journal_sheet.dart';
import '../../features/money/presentation/add_money_sheet.dart';
import '../../features/tasks/presentation/add_task_sheet.dart';
import '../../features/tasks/presentation/task_detail_sheet.dart';
import '../../shared/widgets/glass_bottom_sheet.dart';
import '../../shared/widgets/write_options_sheet.dart';

/// Routes a home/lock screen widget tap (`mindfull://<host><path>`, set by
/// the native widget providers) to the right sheet, habit log or tab. [ref]
/// is only needed for `log-habit`, which reads the habit repository and
/// controller directly rather than through a widget's [BuildContext]. See
/// SPEC.md Home and Lock Screen Widgets.
void navigateFromWidgetUri(Ref ref, GoRouter router, Uri? uri) {
  if (uri == null) {
    return;
  }
  final path = uri.host + uri.path;
  switch (path) {
    case 'open-write-sheet':
      openWriteOptionsSheet(router);
    case 'log-habit':
      final habitId = uri.queryParameters['habitId'];
      if (habitId != null) {
        unawaited(
          _logHabitFromWidget(
            ref,
            habitId,
            uri.queryParameters['action_label'],
          ),
        );
      }
    case 'open-task':
      final taskId = uri.queryParameters['taskId'];
      if (taskId != null) {
        router.go('/home/tasks');
        // The shell's Navigator persists across branch switches, but a
        // frame is given to settle before showing a sheet over it anyway —
        // cheap insurance against showing it over the about-to-be-replaced
        // previous tab.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => openTaskDetailSheet(router, taskId),
        );
      }
    case 'open-habit':
      final habitId = uri.queryParameters['habitId'];
      if (habitId != null) {
        // Unlike a task, a habit's detail view is a real pushed route (the
        // calendar screen), not a sheet — no BuildContext/extra frame
        // needed, `push` is just another go_router navigation.
        router.go('/home/habits');
        router.push('/habits/$habitId');
      }
    case 'home/tasks':
      router.go('/home/tasks');
    case 'home/habits':
      router.go('/home/habits');
  }
}

/// Logs [habitId]'s completion via the action labeled [actionLabel] (or
/// plain "done" if null/not found) — used by the medium widget's action
/// pills, which only carry a habit id and an action label, not the full
/// objects [HabitTabController.logAction] needs. Reuses that method so the
/// widgets get refreshed afterward too, same as logging from in-app.
Future<void> _logHabitFromWidget(
  Ref ref,
  String habitId,
  String? actionLabel,
) async {
  final habitRepository = await ref.read(habitRepositoryProvider.future);
  Habit? habit;
  for (final candidate in habitRepository.getHabits()) {
    if (candidate.id == habitId) {
      habit = candidate;
      break;
    }
  }
  if (habit == null) {
    return;
  }

  HabitAction? action;
  if (actionLabel != null) {
    for (final candidate in habit.actions) {
      if (candidate.label == actionLabel) {
        action = candidate;
        break;
      }
    }
  }

  await ref.read(habitTabControllerProvider.notifier).logAction(habit, action);
}

/// The current screen's [BuildContext], from [router]'s navigator — null
/// only in the brief window before the app's first frame. Every
/// `open*Sheet` helper below opens over whatever that context is showing,
/// since none of these destinations are routes any more, per the
/// bottom-sheet design rules.
BuildContext? _rootContext(GoRouter router) =>
    router.routerDelegate.navigatorKey.currentContext;

/// Opens the write sheet's 3 options (journal/task/habit) as a modal over
/// whatever's currently on screen — used by the medium widget's pencil
/// button (`mindfull://open-write-sheet`).
void openWriteOptionsSheet(GoRouter router) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showWriteOptionsSheet(context);
}

/// Opens [TaskDetailSheet] as a modal over whatever's currently on
/// screen — there's no `/tasks/:id` route to push to any more, since task
/// detail is a bottom sheet, not a page. Used by task reminder taps and
/// home widget taps.
void openTaskDetailSheet(GoRouter router, String taskId) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showGlassBottomSheet(
    context: context,
    builder: (_) => TaskDetailSheet(taskId: taskId),
  );
}

/// Opens [AddTaskSheet] as a modal over whatever's currently on screen —
/// used by the "New Task" app shortcut, since `/tasks/new` isn't a route
/// any more.
void openAddTaskSheet(GoRouter router) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showGlassBottomSheet(context: context, builder: (_) => const AddTaskSheet());
}

/// Opens [AddJournalSheet] as a modal over whatever's currently on
/// screen — used by journal reminder taps and the "New Journal" app
/// shortcut, since `/journal/new` isn't a route any more.
void openAddJournalSheet(GoRouter router) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showGlassBottomSheet(
    context: context,
    builder: (_) => const AddJournalSheet(),
  );
}

/// Opens [AddHabitSheet] as a modal over whatever's currently on screen —
/// used by the "New Habit" app shortcut, since `/habits/new` isn't a route
/// any more.
void openAddHabitSheet(GoRouter router) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showGlassBottomSheet(context: context, builder: (_) => const AddHabitSheet());
}

/// Opens [AddMoneySheet] as a modal over whatever's currently on screen —
/// used by the "Add Money" app shortcut. See SPEC.md Money Flow Feature
/// App shortcuts.
void openAddMoneySheet(GoRouter router) {
  final context = _rootContext(router);
  if (context == null) {
    return;
  }
  showGlassBottomSheet(context: context, builder: (_) => const AddMoneySheet());
}
