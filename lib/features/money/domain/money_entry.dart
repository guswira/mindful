// Analyzer false-positive: @JsonKey on a freezed abstract-class factory
// parameter is valid (json_serializable/freezed both handle it), but the
// analyzer doesn't yet recognize the target as a field.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/sync_status.dart';
import 'budget_type.dart';
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
    // Left out of the upsert while null (an everyday expense), so an app
    // update keeps working against a database without the column yet.
    @JsonKey(name: 'budget_period', includeIfNull: false)
    BudgetType? budgetPeriod,
    @JsonKey(name: 'sync_status')
    @Default(SyncStatus.synced)
    SyncStatus syncStatus,
  }) = _MoneyEntry;

  factory MoneyEntry.fromJson(Map<String, dynamic> json) =>
      _$MoneyEntryFromJson(json);
}

/// Total spending in [entries] that counts against a [budget] budget.
///
/// Income never offsets a budget, and a bill whose
/// [MoneyEntry.budgetPeriod] is longer than [budget] is left out (see
/// [BudgetType.countsToward]); no period means everyday spending, which
/// counts against every budget.
double spendingTowardBudget(Iterable<MoneyEntry> entries, BudgetType budget) {
  var total = 0.0;
  for (final entry in entries) {
    if (entry.type == EntryType.spending &&
        (entry.budgetPeriod ?? BudgetType.daily).countsToward(budget)) {
      total += entry.amount;
    }
  }
  return total;
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
