import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/services/sync_service.dart';
import '../../habits/data/habit_repository.dart';
import '../../journal/data/journal_repository.dart';
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

  /// Signs out, clears the local Hive cache, and returns the app to the
  /// unauthenticated state.
  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    await _clearLocalCache();
    state = const AuthState.unauthenticated();
  }

  Future<void> _clearLocalCache() async {
    for (final boxName in const [
      JournalRepository.boxName,
      HabitRepository.habitsBoxName,
      HabitRepository.habitLogsBoxName,
    ]) {
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
