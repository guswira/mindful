// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';
import 'entry_type.dart';

part 'money_entry.freezed.dart';
part 'money_entry.g.dart';

/// A single spending or income record. See SPEC.md Money Flow Feature Data
/// models.
///
/// Serializes to/from `snake_case` to match the `money_entries` Supabase
/// table directly.
@freezed
abstract class MoneyEntry with _$MoneyEntry {
  const factory MoneyEntry({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required EntryType type,
    required double amount,
    required String category,
    required DateTime date,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? note,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _MoneyEntry;

  factory MoneyEntry.fromJson(Map<String, dynamic> json) =>
      _$MoneyEntryFromJson(json);
}

/// Categories available when [MoneyEntry.type] is [EntryType.spending].
const List<String> spendingCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Health',
  'Entertainment',
  'Bills',
  'Education',
  'Travel',
  'Other',
];

/// Categories available when [MoneyEntry.type] is [EntryType.income].
const List<String> incomeCategories = [
  'Salary',
  'Freelance',
  'Investment',
  'Gift',
  'Other',
];

/// The emoji shown next to each spending/income category.
const Map<String, String> categoryEmoji = {
  'Food': '🍔',
  'Transport': '🚗',
  'Shopping': '🛍',
  'Health': '💊',
  'Entertainment': '🎬',
  'Bills': '📱',
  'Education': '📚',
  'Travel': '✈️',
  'Other': '📦',
  'Salary': '💼',
  'Freelance': '💻',
  'Investment': '📈',
  'Gift': '🎁',
};
