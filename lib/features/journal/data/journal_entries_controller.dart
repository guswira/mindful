import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/widget_service.dart';
import '../../auth/domain/auth_state.dart';
import '../domain/journal_entry.dart';
import 'journal_repository.dart';

part 'journal_entries_controller.g.dart';

/// Journal entries, newest first — cache-backed with Supabase sync.
@riverpod
class JournalEntries extends _$JournalEntries {
  @override
  Future<List<JournalEntry>> build() async {
    final repository = await ref.watch(journalRepositoryProvider.future);
    unawaited(_refreshFromSupabase(repository));
    return repository.getAll();
  }

  /// Pulls the current state of Supabase into the cache so entries created
  /// on another device — or the very first load after signing in on a new
  /// install — show up without waiting for a local write to trigger it.
  Future<void> _refreshFromSupabase(JournalRepository repository) async {
    try {
      await repository.refresh();
      ref.invalidateSelf();
    } catch (_) {
      // Best-effort: the cache is still shown when Supabase is unreachable.
    }
  }

  /// Creates a new entry and refreshes the list.
  Future<void> createEntry({
    required String body,
    String? title,
    Mood? mood,
    List<String> photoUrls = const [],
    DateTime? date,
  }) async {
    final repository = await ref.read(journalRepositoryProvider.future);
    final userId = ref.read(currentUserIdProvider);
    await repository.create(
      userId: userId,
      body: body,
      title: title,
      mood: mood,
      photoUrls: photoUrls,
      date: date,
    );
    ref.invalidateSelf();
    await future;
    await refreshWidgetsBestEffort(() => ref.read(widgetServiceProvider.future));
  }

  /// Saves edits to [entry] and refreshes the list.
  Future<void> updateEntry(JournalEntry entry) async {
    final repository = await ref.read(journalRepositoryProvider.future);
    await repository.update(entry);
    ref.invalidateSelf();
    await future;
    await refreshWidgetsBestEffort(() => ref.read(widgetServiceProvider.future));
  }

  /// Deletes [entry] and refreshes the list.
  Future<void> deleteEntry(JournalEntry entry) async {
    final repository = await ref.read(journalRepositoryProvider.future);
    await repository.delete(entry);
    ref.invalidateSelf();
    await future;
    await refreshWidgetsBestEffort(() => ref.read(widgetServiceProvider.future));
  }

  /// Uploads a photo for use in a not-yet-saved entry.
  Future<String> uploadPhoto({
    required List<int> bytes,
    required String mimeType,
  }) async {
    final repository = await ref.read(journalRepositoryProvider.future);
    final userId = ref.read(currentUserIdProvider);
    return repository.uploadPhoto(
      userId: userId,
      bytes: bytes,
      mimeType: mimeType,
    );
  }
}

/// A single entry looked up from the cached [journalEntriesProvider] list.
@riverpod
JournalEntry? journalEntry(Ref ref, String id) {
  final entries = ref.watch(journalEntriesProvider).valueOrNull;
  if (entries == null) {
    return null;
  }
  for (final entry in entries) {
    if (entry.id == id) {
      return entry;
    }
  }
  return null;
}
