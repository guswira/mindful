import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/journal_entry.dart';

/// Reads, writes and deletes journal entries — and their photos — in
/// Supabase. See SPEC.md Supabase schema.
class SupabaseJournalDatasource {
  SupabaseJournalDatasource({SupabaseClient? client, Uuid? uuid})
    : _clientOverride = client,
      _uuid = uuid ?? const Uuid();

  final SupabaseClient? _clientOverride;
  final Uuid _uuid;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Every journal entry belonging to the signed-in user (RLS-scoped),
  /// newest first.
  Future<List<JournalEntry>> fetchAll() async {
    final rows = await _client
        .from(SupabaseConstants.journalEntriesTable)
        .select()
        .order('date', ascending: false);
    return [for (final row in rows) JournalEntry.fromJson(row)];
  }

  /// Creates or overwrites [entry]'s row.
  Future<void> saveEntry(JournalEntry entry) async {
    await _client
        .from(SupabaseConstants.journalEntriesTable)
        .upsert(entry.toJson());
  }

  /// Deletes [entry]'s row and all of its photos from Storage.
  Future<void> deleteEntry(JournalEntry entry) async {
    await _client
        .from(SupabaseConstants.journalEntriesTable)
        .delete()
        .eq('id', entry.id);
    if (entry.photoUrls.isNotEmpty) {
      await _client.storage
          .from(SupabaseConstants.photosBucket)
          .remove(entry.photoUrls);
    }
  }

  /// Uploads a photo's [bytes] to `photos/{userId}/{uuid}.{ext}` and
  /// returns its Storage path.
  Future<String> uploadPhoto({
    required String userId,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final path = 'photos/$userId/${_uuid.v4()}${_extensionFor(mimeType)}';
    await _client.storage
        .from(SupabaseConstants.photosBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );
    return path;
  }

  /// A short-lived signed URL for displaying the private photo at [path].
  Future<String> signedPhotoUrl(String path) {
    return _client.storage
        .from(SupabaseConstants.photosBucket)
        .createSignedUrl(path, 3600);
  }

  static String _extensionFor(String mimeType) => switch (mimeType) {
    'image/png' => '.png',
    'image/heic' => '.heic',
    _ => '.jpg',
  };
}
