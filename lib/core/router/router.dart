import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/ai/presentation/ai_tab.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/habits/data/habit_reminders_controller.dart';
import '../../features/habits/presentation/habit_detail_screen.dart';
import '../../features/habits/presentation/habit_tab.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_tab.dart';
import '../../features/journal/presentation/journal_editor_screen.dart';
import '../../features/journal/presentation/journal_tab.dart';
import '../../features/money/presentation/money_tab.dart';
import '../../features/settings/data/journal_reminders_controller.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tasks/data/task_reminders_controller.dart';
import '../../features/tasks/presentation/task_tab.dart';
import '../../shared/services/notification_service.dart';
import 'sheet_navigation.dart';

export 'sheet_navigation.dart'
    show
        openAddHabitSheet,
        openAddJournalSheet,
        openAddMoneySheet,
        openAddTaskSheet;

part 'router.g.dart';

const String _splashLocation = '/splash';
const String _loginLocation = '/login';
const String _homeLocation = '/home/today';

/// go_router config — routes from SPEC.md Navigation section.
///
/// Redirect: unauthenticated users are always sent to [_loginLocation].
/// Redirect: authenticated users hitting [_loginLocation] or
/// [_splashLocation] are sent to [_homeLocation].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authListenable = _AuthChangeNotifier(ref);
  ref.onDispose(authListenable.dispose);

  // Reconciles the OS-level reminder schedule with the saved toggle state
  // on every app start, without making the router rebuild when it's later
  // toggled from Settings (a plain watch would do that).
  ref.read(journalRemindersProvider);
  // Same idea for habit/task reminders — these have no user-facing toggle
  // to react to, but still need re-arming on every app start (see
  // taskReminders/habitReminders' own doc comments for why).
  ref.read(taskRemindersProvider);
  ref.read(habitRemindersProvider);

  final router = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: _splashLocation,
    refreshListenable: authListenable,
    redirect: (context, state) =>
        _redirect(ref.read(authNotifierProvider), state),
    // Defense in depth: the known cause of an unroutable location — a
    // widget tap's launch Intent handing its `mindful://` data URI to
    // FlutterActivity as an initial route — is disabled via
    // flutter_deeplinking_enabled in AndroidManifest.xml. This is just a
    // backstop against any other stray location, so it never crashes the
    // app; it resets to the splash screen, which redirects correctly for
    // whatever the auth state actually is.
    errorBuilder: (context, state) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => GoRouter.of(context).go(_splashLocation),
      );
      return const SizedBox.shrink();
    },
    routes: [
      GoRoute(
        path: _splashLocation,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: _loginLocation,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/today',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/tasks',
                builder: (context, state) => const TaskTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/habits',
                builder: (context, state) => const HabitTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/journal',
                builder: (context, state) => const JournalTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/money',
                builder: (context, state) => const MoneyTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/ai',
                builder: (context, state) => const AITab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/journal/:id/edit',
        builder: (context, state) =>
            JournalEditorScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) =>
            HabitDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.listen(notificationTapProvider, (previous, next) {
    final payload = next.valueOrNull;
    if (payload == null) {
      return;
    }
    if (payload == NotificationService.journalPayload) {
      openAddJournalSheet(router);
      return;
    }
    if (payload == NotificationService.foodScanPayload) {
      router.go('/home/ai');
      return;
    }
    if (payload == NotificationService.moneyAdvicePayload) {
      router.go('/home/money');
      return;
    }
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      if (decoded['taskId'] case final String taskId) {
        openTaskDetailSheet(router, taskId);
      }
    } catch (_) {
      // Not a task payload (e.g. a habit reminder) — no tap navigation for
      // those yet.
    }
  });

  // Home/lock screen widget taps: `mindful://open-write-sheet`,
  // `mindful://log-habit`, `mindful://open-task`, `mindful://home/tasks`
  // and `mindful://home/habits`, set by the native widget providers. See
  // SPEC.md Home and Lock Screen Widgets.
  unawaited(
    HomeWidget.initiallyLaunchedFromHomeWidget().then(
      (uri) => navigateFromWidgetUri(ref, router, uri),
    ),
  );
  HomeWidget.widgetClicked.listen(
    (uri) => navigateFromWidgetUri(ref, router, uri),
  );

  return router;
}

String? _redirect(AuthState authState, GoRouterState routerState) {
  final location = routerState.matchedLocation;
  final onSplash = location == _splashLocation;
  final onLogin = location == _loginLocation;

  return switch (authState) {
    AuthUnknown() => onSplash ? null : _splashLocation,
    AuthUnauthenticated() => onLogin ? null : _loginLocation,
    AuthAuthenticated() => (onSplash || onLogin) ? _homeLocation : null,
  };
}

/// Bridges [authNotifierProvider] changes to a [Listenable] so `go_router`
/// re-evaluates its redirect without rebuilding the whole router.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (previous, next) => notifyListeners());
  }
}
