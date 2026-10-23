import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/ai/presentation/ai_tab.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/exercise/domain/breathing_exercise.dart';
import '../../features/exercise/presentation/breathing_session_screen.dart'
    deferred as breathing_session;
import '../../features/exercise/presentation/exercise_activity_screen.dart'
    deferred as exercise_activity;
import '../../features/habits/data/habit_reminders_controller.dart';
import '../../features/habits/presentation/habit_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_tab.dart';
import '../../features/journal/presentation/journal_editor_screen.dart';
import '../../features/journal/presentation/journal_history_screen.dart';
import '../../features/journal/presentation/journal_tab.dart';
import '../../features/money/presentation/money_tab.dart';
import '../../features/plan/presentation/plan_tab.dart';
import '../../features/recap/domain/recap_window.dart';
import '../../features/recap/presentation/monthly_recap_screen.dart'
    deferred as monthly_recap;
import '../../features/settings/data/journal_reminders_controller.dart';
import '../../features/settings/presentation/settings_screen.dart'
    deferred as settings;
import '../../features/tasks/data/task_reminders_controller.dart';
import '../../features/exercise/presentation/exercise_providers.dart';
import '../../features/habits/presentation/habit_tab.dart';
import '../../features/journal/data/journal_entries_controller.dart';
import '../../features/money/presentation/money_providers.dart';
import '../../features/tasks/presentation/task_tab.dart';
import '../../shared/services/quote_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/web/web_loader.dart';
import '../../shared/widgets/deferred_screen.dart';
import '../platform/platform_features.dart';
import 'sheet_navigation.dart';

export 'sheet_navigation.dart'
    show
        openAddHabitSheet,
        openAddJournalSheet,
        openAddMoneySheet,
        openAddTaskSheet;

const String _splashLocation = '/splash';
const String _loginLocation = '/login';
const String _homeLocation = '/home/today';

/// The app's one [GoRouter], kept alive for the app's lifetime.
///
/// Written by hand rather than with `@Riverpod`: this file imports every
/// screen, and riverpod_generator's analyzer (pinned by Riverpod 2) can't
/// read the newer Dart syntax in liquid_glass_widgets, which those screens
/// pull in — see build.yaml.
final appRouterProvider = Provider<GoRouter>(_appRouter);

/// go_router config — routes from SPEC.md Navigation section.
///
/// Redirect: unauthenticated users are always sent to [_loginLocation].
/// Redirect: authenticated users hitting [_loginLocation] or
/// [_splashLocation] are sent to [_homeLocation].
GoRouter _appRouter(Ref ref) {
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
                builder: (context, state) => const PlanTab(),
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
      // Exercise was merged into the Mindfulness tab; kept so any
      // stale link still lands somewhere sensible.
      GoRoute(path: '/home/exercise', redirect: (_, _) => '/home/journal'),
      GoRoute(
        path: '/journal/history',
        builder: (context, state) => const JournalHistoryScreen(),
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
        path: '/exercise/activity',
        builder: (context, state) => DeferredScreen(
          load: exercise_activity.loadLibrary,
          builder: (_) => exercise_activity.ExerciseActivityScreen(),
        ),
      ),
      GoRoute(
        path: '/exercise/breathing/:exercise',
        builder: (context, state) => DeferredScreen(
          load: breathing_session.loadLibrary,
          builder: (_) => breathing_session.BreathingSessionScreen(
            exercise:
                BreathingExercise.fromName(state.pathParameters['exercise']) ??
                BreathingExercise.equal,
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => DeferredScreen(
          load: settings.loadLibrary,
          builder: (_) => settings.SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/recap/:month',
        builder: (context, state) => DeferredScreen(
          load: monthly_recap.loadLibrary,
          builder: (_) => monthly_recap.MonthlyRecapScreen(
            month:
                parseRecapMonthKey(state.pathParameters['month']) ??
                previousMonth(DateTime.now()),
          ),
        ),
      ),
    ],
  );

  if (isWebPlatform) {
    _hideWebLoaderOnceOffSplash(router, ref);
  }

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
  // and `mindful://home/habits` (both land on the Tasks & Routines tab),
  // set by the native widget providers. See
  // SPEC.md Home and Lock Screen Widgets. Phones only — home_widget has
  // no desktop/web implementation.
  if (isPhonePlatform) {
    unawaited(
      HomeWidget.initiallyLaunchedFromHomeWidget().then(
        (uri) => navigateFromWidgetUri(ref, router, uri),
      ),
    );
    HomeWidget.widgetClicked.listen(
      (uri) => navigateFromWidgetUri(ref, router, uri),
    );
  }

  return router;
}

/// Keeps web/index.html's loader up through the splash (the auth check)
/// and fades it out only after the first real screen — login or home —
/// has painted, so the page goes loader → screen with no spinner between.
void _hideWebLoaderOnceOffSplash(GoRouter router, Ref ref) {
  final delegate = router.routerDelegate;
  void onRouteChanged() {
    final path = delegate.currentConfiguration.uri.path;
    if (path.isEmpty || path == _splashLocation) {
      return;
    }
    delegate.removeListener(onRouteChanged);
    // After the frame that draws the new route, not before it.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_hideWebLoaderWhenSettled(ref, path)),
    );
  }

  delegate.addListener(onRouteChanged);
}

/// The longest a signed-in launch holds the loader for Home's data — past
/// it, the screen shows with whatever has loaded.
const Duration _homeSettleTimeout = Duration(milliseconds: 1500);

/// On a Home tab, waits for the cached (Hive) data its cards show — so the
/// screen fades in complete instead of cards popping in behind or right
/// after the fade — then hides the loader after the frame that draws it.
/// Network-only data (food scans, the Supabase sync) isn't waited for.
///
/// Runs after Home's first frame, when its widgets already watch these
/// (auto-dispose) providers — reading them earlier would load each twice.
Future<void> _hideWebLoaderWhenSettled(Ref ref, String path) async {
  if (path.startsWith('/home')) {
    Future<void> settled(Future<Object?> future) =>
        future.then<void>((_) {}, onError: (Object _) {});
    await Future.wait([
      settled(ref.read(taskTabControllerProvider.future)),
      settled(ref.read(habitTabControllerProvider.future)),
      settled(ref.read(activeBudgetsProvider.future)),
      settled(ref.read(remainingBudgetProvider.future)),
      settled(ref.read(dailyQuoteProvider.future)),
      settled(ref.read(journalEntriesProvider.future)),
      settled(ref.read(breathingSessionsProvider.future)),
    ]).timeout(_homeSettleTimeout, onTimeout: () => const []);
    // Let the cards rebuild with that data before revealing them.
    await WidgetsBinding.instance.endOfFrame;
  }
  hideWebLoader();
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
