import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/sync_status.dart';
import '../domain/budget_settings.dart';
import '../domain/budget_type.dart';
import '../domain/entry_type.dart';
import '../domain/money_entry.dart';
import 'supabase_money_datasource.dart';

part 'money_repository.g.dart';

/// Budget settings + money entry CRUD, backed by a Hive cache and synced
/// to Supabase through [SupabaseMoneyDatasource]. Writes go to cache
/// first (optimistic), then to Supabase, per SPEC.md's storage strategy:
/// an entry write that fails to reach Supabase stays in the cache marked
/// [SyncStatus.pending]. Budget settings have no `sync_status` column
/// (one row per user per [BudgetType]), so a failed settings sync is
/// surfaced to the caller instead — same tradeoff as
/// [HabitRepository.saveHabit].
class MoneyRepository {
  MoneyRepository({
    required Box<dynamic> entriesBox,
    required Box<dynamic> settingsBox,
    SupabaseMoneyDatasource? datasource,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _entriesBox = entriesBox,
       _settingsBox = settingsBox,
       _datasource = datasource ?? SupabaseMoneyDatasource(),
       _storage = storage;

  /// The Hive box names this repository caches into.
  static const String entriesBoxName = 'money_entries';
  static const String settingsBoxName = 'budget_settings';

  static const String _currencyKey = 'budget_currency';

  final Box<dynamic> _entriesBox;
  final Box<dynamic> _settingsBox;
  final SupabaseMoneyDatasource _datasource;
  final FlutterSecureStorage _storage;

  static String _settingsCacheKey(BudgetType type) => 'settings_${type.name}';

  /// The cached budget settings for [type], or null if that budget hasn't
  /// been set yet. Refreshed from Supabase on app open by `SyncService`.
  BudgetSettings? getBudgetSettings(BudgetType type) {
    final value = _settingsBox.get(_settingsCacheKey(type));
    if (value == null) {
      return null;
    }
    try {
      return BudgetSettings.fromJson(_asJsonMap(value));
    } catch (error) {
      debugPrint('Skipping unreadable cached budget settings: $error');
      return null;
    }
  }

  /// Every budget that's been set — monthly, daily, or both.
  List<BudgetSettings> getAllBudgetSettings() => [
    for (final type in BudgetType.values)
      if (getBudgetSettings(type) case final settings?) settings,
  ];

  /// Caches [settings] under its own [BudgetSettings.budgetType], then
  /// upserts it in Supabase (matching on `user_id, budget_type`, so
  /// monthly and daily are independent rows). Throws if the Supabase sync
  /// fails — see class doc.
  Future<void> saveBudgetSettings(BudgetSettings settings) async {
    await _settingsBox.put(
      _settingsCacheKey(settings.budgetType),
      settings.toJson(),
    );
    await _datasource.saveBudgetSettings(settings);
  }

  /// The currency both budgets are set in — shared rather than tracked
  /// per budget, so changing it in one place is reflected in the other.
  /// Defaults to IDR (the app's default currency) until explicitly set.
  Future<String> getCurrency() async =>
      await _storage.read(key: _currencyKey) ?? 'IDR';

  /// Updates the shared currency used by both budgets.
  Future<void> setCurrency(String currency) =>
      _storage.write(key: _currencyKey, value: currency);

  /// Cached money entries within [range] (inclusive), newest first — by
  /// date, then by creation time. A null [range] returns every cached
  /// entry. Skips any record that fails to decode (e.g. cached by an
  /// older, incompatible app version) instead of letting one bad entry
  /// take down the whole list.
  List<MoneyEntry> getEntries({DateTimeRange? range}) {
    final entries = <MoneyEntry>[];
    for (final value in _entriesBox.values) {
      try {
        entries.add(_decodeEntry(value));
      } catch (error) {
        debugPrint('Skipping unreadable cached money entry: $error');
      }
    }
    final filtered = range == null
        ? entries
        : entries.where((entry) => _inRange(entry.date, range)).toList();
    filtered.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  /// Caches a new [entry], then inserts it in Supabase.
  Future<void> createEntry(MoneyEntry entry) =>
      _writeOptimistic(entry, () => _datasource.createEntry(entry));

  /// Caches edits to an existing [entry], then updates it in Supabase.
  Future<void> updateEntry(MoneyEntry entry) =>
      _writeOptimistic(entry, () => _datasource.updateEntry(entry));

  /// Deletes the money entry with [id] from cache and Supabase.
  Future<void> deleteEntry(String id) async {
    await _entriesBox.delete(id);
    await _datasource.deleteEntry(id);
  }

  /// Retries every entry still marked [SyncStatus.pending].
  Future<void> retryPendingEntries() async {
    for (final entry in getEntries()) {
      if (entry.syncStatus == SyncStatus.pending) {
        await updateEntry(entry.copyWith(syncStatus: SyncStatus.synced));
      }
    }
  }

  /// Replaces the cache with the current state of Supabase — every money
  /// entry and every budget that's been set.
  Future<void> refresh() async {
    final entries = await _datasource.getEntries();
    await _entriesBox.clear();
    for (final entry in entries) {
      await _entriesBox.put(entry.id, entry.toJson());
    }
    final allSettings = await _datasource.getAllBudgetSettings();
    for (final settings in allSettings) {
      await _settingsBox.put(
        _settingsCacheKey(settings.budgetType),
        settings.toJson(),
      );
    }
  }

  /// Total spending within [range] (inclusive), or all-time if null.
  double getTotalSpending({DateTimeRange? range}) =>
      _sum(EntryType.spending, range);

  /// Total income within [range] (inclusive), or all-time if null.
  double getTotalIncome({DateTimeRange? range}) =>
      _sum(EntryType.income, range);

  double _sum(EntryType type, DateTimeRange? range) {
    var total = 0.0;
    for (final entry in getEntries(range: range)) {
      if (entry.type == type) {
        total += entry.amount;
      }
    }
    return total;
  }

  /// [type]'s budget amount minus this period's spending, or 0 if that
  /// budget hasn't been set. Income doesn't offset a budget's remaining
  /// amount — it's only reflected in the recap.
  double getRemaining(BudgetType type) {
    final settings = getBudgetSettings(type);
    if (settings == null) {
      return 0;
    }
    final range = getPeriodRange(type);
    return settings.amount - getTotalSpending(range: range);
  }

  /// [type]'s current period: the 1st of this month through today for
  /// [BudgetType.monthly], or just today for [BudgetType.daily].
  DateTimeRange getPeriodRange(BudgetType type) {
    final today = _dateOnly(DateTime.now());
    final start = type == BudgetType.monthly
        ? DateTime(today.year, today.month, 1)
        : today;
    return DateTimeRange(start: start, end: today);
  }

  Future<void> _writeOptimistic(
    MoneyEntry entry,
    Future<void> Function() sync,
  ) async {
    await _entriesBox.put(entry.id, entry.toJson());
    try {
      await sync();
    } catch (_) {
      await _entriesBox.put(
        entry.id,
        entry.copyWith(syncStatus: SyncStatus.pending).toJson(),
      );
    }
  }

  static bool _inRange(DateTime date, DateTimeRange range) =>
      !date.isBefore(range.start) && !date.isAfter(range.end);

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Hive returns nested maps/lists with loose (`dynamic`) generics, which
  /// `fromJson` rejects. Round-tripping through `jsonEncode`/`jsonDecode`
  /// re-materializes them with the `Map<String, dynamic>` shape it expects.
  MoneyEntry _decodeEntry(Object value) =>
      MoneyEntry.fromJson(_asJsonMap(value));

  static Map<String, dynamic> _asJsonMap(Object value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

/// The Hive box caching money entries, keyed by entry id.
@Riverpod(keepAlive: true)
Future<Box<dynamic>> moneyEntriesBox(Ref ref) =>
    Hive.openBox<dynamic>(MoneyRepository.entriesBoxName);

/// The Hive box caching budget settings — up to one row per [BudgetType].
@Riverpod(keepAlive: true)
Future<Box<dynamic>> budgetSettingsBox(Ref ref) =>
    Hive.openBox<dynamic>(MoneyRepository.settingsBoxName);

/// The app-wide [MoneyRepository], backed by the opened Hive boxes.
@Riverpod(keepAlive: true)
Future<MoneyRepository> moneyRepository(Ref ref) async {
  final entriesBox = await ref.watch(moneyEntriesBoxProvider.future);
  final settingsBox = await ref.watch(budgetSettingsBoxProvider.future);
  return MoneyRepository(entriesBox: entriesBox, settingsBox: settingsBox);
}
