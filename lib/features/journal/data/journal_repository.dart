import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/sync_status.dart';
import '../domain/journal_entry.dart';
import 'supabase_journal_datasource.dart';

part 'journal_repository.g.dart';

/// Journal CRUD backed by a Hive cache, synced to Supabase through
/// [SupabaseJournalDatasource]. Writes go to cache first (optimistic),
/// then to Supabase, per SPEC.md's storage strategy: a write that fails to
/// reach Supabase stays in the cache marked [SyncStatus.pending].
class JournalRepository {
  JournalRepository({
    required SupabaseJournalDatasource datasource,
    required Box<dynamic> cacheBox,
    Uuid uuid = const Uuid(),
  }) : _datasource = datasource,
       _cacheBox = cacheBox,
       _uuid = uuid;

  /// The Hive box name this repository caches into.
  static const String boxName = 'journal_entries';

  final SupabaseJournalDatasource _datasource;
  final Box<dynamic> _cacheBox;
  final Uuid _uuid;

  /// All cached entries, newest first. Skips any record that fails to
  /// decode (e.g. cached by an older, incompatible app version) instead of
  /// letting one bad entry take down the whole list.
  List<JournalEntry> getAll() {
    final entries = <JournalEntry>[];
    for (final value in _cacheBox.values) {
      try {
        entries.add(_decode(value));
      } catch (error) {
        debugPrint('Skipping unreadable cached journal entry: $error');
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Replaces the cache with the current state of Supabase.
  Future<List<JournalEntry>> refresh() async {
    final entries = await _datasource.fetchAll();
    await _cacheBox.clear();
    for (final entry in entries) {
      await _cacheBox.put(entry.id, entry.toJson());
    }
    return getAll();
  }

  /// Creates a new entry for [userId], writing to cache before syncing to
  /// Supabase.
  Future<JournalEntry> create({
    required String userId,
    required String body,
    String? title,
    Mood? mood,
    List<String> photoUrls = const [],
    DateTime? date,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: _uuid.v4(),
      userId: userId,
      date: date ?? now,
      title: title,
      body: body,
      mood: mood,
      photoUrls: photoUrls,
      createdAt: now,
      updatedAt: now,
    );
    await _save(entry);
    return entry;
  }

  /// Saves edits to an existing entry, bumping [JournalEntry.updatedAt].
  Future<JournalEntry> update(JournalEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now());
    await _save(updated);
    return updated;
  }

  /// Deletes an entry — and its photos — from cache and Supabase.
  Future<void> delete(JournalEntry entry) async {
    await _cacheBox.delete(entry.id);
    await _datasource.deleteEntry(entry);
  }

  /// Uploads a photo to Supabase Storage and returns its path.
  Future<String> uploadPhoto({
    required String userId,
    required List<int> bytes,
    required String mimeType,
  }) {
    return _datasource.uploadPhoto(
      userId: userId,
      bytes: Uint8List.fromList(bytes),
      mimeType: mimeType,
    );
  }

  /// A short-lived signed URL for displaying the private photo at [path].
  Future<String> signedPhotoUrl(String path) =>
      _datasource.signedPhotoUrl(path);

  /// Retries every journal entry still marked [SyncStatus.pending].
  Future<void> retryPendingEntries() async {
    for (final entry in getAll()) {
      if (entry.syncStatus == SyncStatus.pending) {
        await _save(entry.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }

  Future<void> _save(JournalEntry entry) async {
    await _cacheBox.put(entry.id, entry.toJson());
    try {
      await _datasource.saveEntry(entry);
    } catch (_) {
      await _cacheBox.put(
        entry.id,
        entry.copyWith(syncStatus: SyncStatus.pending).toJson(),
      );
    }
  }

  /// Hive returns nested maps/lists with loose (`dynamic`) generics, which
  /// `fromJson` rejects. Round-tripping through `jsonEncode`/`jsonDecode`
  /// re-materializes them with the `Map<String, dynamic>` shape it expects.
  JournalEntry _decode(Object value) => JournalEntry.fromJson(
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
  );
}

@Riverpod(keepAlive: true)
Future<JournalRepository> journalRepository(Ref ref) async {
  final box = await Hive.openBox<dynamic>(JournalRepository.boxName);
  return JournalRepository(
    datasource: SupabaseJournalDatasource(),
    cacheBox: box,
  );
}
