import 'package:flutter/material.dart' show DateTimeRange;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/budget_settings.dart';
import '../domain/budget_type.dart';
import '../domain/money_entry.dart';

/// Reads and writes budget settings and money entries in Supabase. See
/// SPEC.md Money Flow Feature Supabase schema.
class SupabaseMoneyDatasource {
  SupabaseMoneyDatasource({SupabaseClient? client}) : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// The signed-in user's budget settings for [type], or null if that
  /// budget hasn't been set.
  Future<BudgetSettings?> getBudgetSettings(BudgetType type) async {
    final row = await _client
        .from(SupabaseConstants.budgetSettingsTable)
        .select()
        .eq('budget_type', type.name)
        .maybeSingle();
    return row == null ? null : BudgetSettings.fromJson(row);
  }

  /// Every budget row belonging to the signed-in user (RLS-scoped) — up
  /// to one per [BudgetType].
  Future<List<BudgetSettings>> getAllBudgetSettings() async {
    final rows = await _client
        .from(SupabaseConstants.budgetSettingsTable)
        .select();
    return [for (final row in rows) BudgetSettings.fromJson(row)];
  }

  /// Creates or overwrites the signed-in user's budget settings row for
  /// [settings]'s [BudgetSettings.budgetType] — each period is an
  /// independent row (`unique(user_id, budget_type)`).
  Future<void> saveBudgetSettings(BudgetSettings settings) async {
    await _client
        .from(SupabaseConstants.budgetSettingsTable)
        .upsert(settings.toJson(), onConflict: 'user_id,budget_type');
  }

  /// Every money entry belonging to the signed-in user, newest first —
  /// optionally restricted to dates within [range] (inclusive).
  ///
  /// Filtered by user explicitly: RLS also lets a linked partner's shared
  /// spending through, and that must never land in this user's own cache.
  Future<List<MoneyEntry>> getEntries({DateTimeRange? range}) async {
    var query = _client.from(SupabaseConstants.moneyEntriesTable).select();
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    if (range != null) {
      query = query
          .gte('date', _dateOnly(range.start))
          .lte('date', _dateOnly(range.end));
    }
    final rows = await query
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return [for (final row in rows) MoneyEntry.fromJson(row)];
  }

  /// Inserts a new money entry row.
  Future<void> createEntry(MoneyEntry entry) => _withoutMissingVisibility(
    entry.toJson(),
    (json) => _client.from(SupabaseConstants.moneyEntriesTable).insert(json),
  );

  /// Runs [write] with [json]; when the database hasn't got the
  /// `visibility` column yet (not migrated), retries without it — the
  /// entry then stays private, which is what the column defaults to.
  Future<void> _withoutMissingVisibility(
    Map<String, dynamic> json,
    Future<void> Function(Map<String, dynamic> json) write,
  ) async {
    try {
      await write(json);
    } on PostgrestException catch (error) {
      if (error.code != _unknownColumnCode ||
          !error.message.contains(_visibilityColumn)) {
        rethrow;
      }
      await write({...json}..remove(_visibilityColumn));
    }
  }

  /// Updates an existing money entry row.
  ///
  /// `budget_period` is left out of [MoneyEntry.toJson] while null, which
  /// on an update would keep the old period — so it's cleared explicitly,
  /// unless the column doesn't exist yet (database not migrated), where
  /// there's nothing to clear.
  Future<void> updateEntry(MoneyEntry entry) async {
    final json = entry.toJson();
    if (json.containsKey(_budgetPeriodColumn)) {
      await _update(entry.id, json);
      return;
    }
    try {
      await _update(entry.id, {...json, _budgetPeriodColumn: null});
    } on PostgrestException catch (error) {
      if (error.code != _unknownColumnCode) rethrow;
      await _update(entry.id, json);
    }
  }

  static const String _budgetPeriodColumn = 'budget_period';
  static const String _visibilityColumn = 'visibility';

  /// PostgREST's "column not found in the schema cache".
  static const String _unknownColumnCode = 'PGRST204';

  Future<void> _update(String id, Map<String, dynamic> json) =>
      _withoutMissingVisibility(
        json,
        (json) => _client
            .from(SupabaseConstants.moneyEntriesTable)
            .update(json)
            .eq('id', id),
      );

  /// Deletes the money entry with [id].
  Future<void> deleteEntry(String id) async {
    await _client
        .from(SupabaseConstants.moneyEntriesTable)
        .delete()
        .eq('id', id);
  }

  static String _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
}
