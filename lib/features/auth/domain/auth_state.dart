import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/services/notification_service.dart';
import '../../../shared/services/sync_service.dart';
import '../../../shared/services/widget_service.dart';
import '../../exercise/data/breathing_session_repository.dart';
import '../../habits/data/habit_repository.dart';
import '../../journal/data/journal_repository.dart';
import '../../money/data/money_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../data/auth_repository.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

/// Authentication state for the app, driven by the Supabase session.
///
/// Starts as [AuthState.unknown] while the session restore check is in
/// flight, then settles into [AuthState.authenticated] or
/// [AuthState.unauthenticated].
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthUnknown;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}

/// Drives [AuthState] from [AuthRepository] and exposes sign-in/out actions.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState.unknown();
  }

  Future<void> _restoreSession() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.initialize();
      final user = await repository.attemptSilentSignIn();
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user);
        _syncOnOpen();
      }
    } catch (_) {
      // Any failure to restore a session (no plugin available, expired
      // grant, network error, ...) is treated as signed out.
      state = const AuthState.unauthenticated();
    }
  }

  /// Starts an interactive Google sign-in, exchanged for a Supabase
  /// session. Throws on cancellation or failure; [state] is left unchanged
  /// so the caller can retry.
  Future<void> signIn() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.initialize();
    final user = await repository.signIn();
    state = AuthState.authenticated(user);
    _syncOnOpen();
  }

  /// Kicks off a best-effort Supabase sync in the background — the cache
  /// is shown immediately either way, per SPEC.md's storage strategy.
  /// [SyncService.syncOnOpen] also refreshes the home/lock screen widgets.
  Future<void> _syncOnOpen() async {
    try {
      final syncService = await ref.read(syncServiceProvider.future);
      await syncService.syncOnOpen();
    } catch (_) {
      // Best-effort: retried on the next app open.
    }
  }

  /// Hive boxes holding the signed-in account's data. Every one is emptied
  /// on sign-out — a box missed here shows the previous account's data to
  /// whoever signs in next, since sync merges into the cache rather than
  /// replacing it.
  ///
  /// Device preferences (language, background, breathing sound settings)
  /// live in secure storage, not here, and survive a sign-out on purpose.
  static const List<String> userDataBoxNames = [
    JournalRepository.boxName,
    HabitRepository.habitsBoxName,
    HabitRepository.habitLogsBoxName,
    TaskRepository.boxName,
    MoneyRepository.entriesBoxName,
    MoneyRepository.settingsBoxName,
    BreathingSessionRepository.boxName,
  ];

  /// Signs out, then drops everything that belonged to the account: its
  /// task/habit reminders, the local Hive cache and the home/lock screen
  /// widgets' copy of it.
  ///
  /// Unsynced (pending) local writes are lost — they'd otherwise be
  /// uploaded later under whichever account signs in next.
  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    await _forgetReminders();
    await _clearLocalCache();
    // SyncService skips a sync within 5 minutes of the last one — a fresh
    // instance makes sure the next account pulls its data straight away.
    ref.invalidate(syncServiceProvider);
    state = const AuthState.unauthenticated();
    await refreshWidgetsBestEffort(
      () => ref.read(widgetServiceProvider.future),
    );
  }

  Future<void> _forgetReminders() async {
    try {
      final notifications = await ref.read(notificationServiceProvider.future);
      await notifications.forgetAllItemReminders();
    } catch (error) {
      // Best-effort: signing out must still succeed without notifications.
      debugPrint('Could not cancel reminders on sign-out: $error');
    }
  }

  Future<void> _clearLocalCache() async {
    for (final boxName in userDataBoxNames) {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName);
      await box.clear();
    }
  }
}

/// The signed-in user's Supabase id.
///
/// Throws if read while unauthenticated — callers only run once the
/// router's redirect guard has already required an authenticated session.
@riverpod
String currentUserId(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return switch (authState) {
    AuthAuthenticated(:final user) => user.id,
    _ => throw StateError('No signed-in user.'),
  };
}
