// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

/// A journal entry's self-reported emotional state.
enum Mood {
  happy,
  neutral,
  sad,
  anxious,
  excited;

  /// The emoji shown for this mood in pickers and entry cards.
  String get emoji => switch (this) {
    Mood.happy => '😊',
    Mood.neutral => '😐',
    Mood.sad => '😢',
    Mood.anxious => '😰',
    Mood.excited => '🤩',
  };
}

/// A single day's journal entry. See SPEC.md Data models.
///
/// Serializes to/from `snake_case` to match the `journal_entries` Supabase
/// table directly.
@freezed
abstract class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required DateTime date,
    required String body,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? title,
    Mood? mood,
    // Supabase Storage paths, e.g. `photos/{user_id}/{uuid}.jpg`.
    @JsonKey(name: 'photo_urls') @Default(<String>[]) List<String> photoUrls,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}
