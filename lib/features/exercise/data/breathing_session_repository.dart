import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/sync_status.dart';
import '../domain/breathing_session.dart';
import 'supabase_breathing_datasource.dart';

part 'breathing_session_repository.g.dart';

/// Breathing session history, cached in Hive and synced to Supabase.
/// Writes go to the cache first; one that fails to reach Supabase stays
/// cached as [SyncStatus.pending] and is retried by `SyncService`.
class BreathingSessionRepository {
  BreathingSessionRepository({
    required Box<dynamic> box,
    SupabaseBreathingDatasource? datasource,
  }) : _box = box,
       _datasource = datasource ?? SupabaseBreathingDatasource();

  static const String boxName = 'breathing_sessions';

  final Box<dynamic> _box;
  final SupabaseBreathingDatasource _datasource;

  /// Every cached session, newest first. Skips records that fail to
  /// decode instead of letting one bad row hide the whole history.
  List<BreathingSession> getSessions() {
    final sessions = <BreathingSession>[];
    for (final value in _box.values) {
      try {
        sessions.add(_decode(value));
      } catch (error) {
        debugPrint('Skipping unreadable cached breathing session: $error');
      }
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  /// Caches [session], then saves it to Supabase.
  Future<void> saveSession(BreathingSession session) async {
    await _box.put(session.id, session.toJson());
    try {
      await _datasource.saveSession(session);
    } catch (error) {
      debugPrint('Breathing session sync failed, will retry: $error');
      await _box.put(
        session.id,
        session.copyWith(syncStatus: SyncStatus.pending).toJson(),
      );
    }
  }

  /// Retries every session still marked [SyncStatus.pending].
  Future<void> retryPendingSessions() async {
    for (final session in getSessions()) {
      if (session.syncStatus == SyncStatus.pending) {
        await saveSession(session.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }

  /// Replaces the cache with Supabase's copy, keeping any session that
  /// still hasn't synced so a refresh can never lose it.
  Future<void> refresh() async {
    final remote = await _datasource.getSessions();
    final pending = [
      for (final session in getSessions())
        if (session.syncStatus == SyncStatus.pending) session,
    ];
    await _box.clear();
    for (final session in [...remote, ...pending]) {
      await _box.put(session.id, session.toJson());
    }
  }

  /// Hive hands back loosely typed maps; round-tripping through JSON gives
  /// `fromJson` the `Map<String, dynamic>` it expects.
  static BreathingSession _decode(Object value) => BreathingSession.fromJson(
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
  );
}

/// The Hive box caching breathing sessions, keyed by session id.
@Riverpod(keepAlive: true)
Future<Box<dynamic>> breathingSessionsBox(Ref ref) =>
    Hive.openBox<dynamic>(BreathingSessionRepository.boxName);

/// The app-wide [BreathingSessionRepository].
@Riverpod(keepAlive: true)
Future<BreathingSessionRepository> breathingSessionRepository(Ref ref) async {
  final box = await ref.watch(breathingSessionsBoxProvider.future);
  return BreathingSessionRepository(box: box);
}
