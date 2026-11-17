import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../domain/entry_type.dart';
import '../domain/entry_visibility.dart';
import '../domain/money_entry.dart';
import '../domain/money_partner.dart';
import 'supabase_money_partner_datasource.dart';

/// The linked partner and their shared spending, cached in Hive so the
/// Money tab and budgets work offline. Read-only on the partner's data —
/// only they can change their entries. See SPEC.md Money Flow Feature
/// Linked partner.
class MoneyPartnerRepository {
  MoneyPartnerRepository({
    required Box<dynamic> partnerBox,
    required Box<dynamic> entriesBox,
    SupabaseMoneyPartnerDatasource? datasource,
  }) : _partnerBox = partnerBox,
       _entriesBox = entriesBox,
       _datasource = datasource ?? SupabaseMoneyPartnerDatasource();

  /// The Hive box names this repository caches into (account boxes —
  /// cleared on sign-out).
  static const String partnerBoxName = 'money_partner';
  static const String entriesBoxName = 'partner_money_entries';

  static const String _partnerKey = 'partner';

  final Box<dynamic> _partnerBox;
  final Box<dynamic> _entriesBox;
  final SupabaseMoneyPartnerDatasource _datasource;

  /// The cached partner, or null when not linked.
  MoneyPartner? getPartner() {
    final value = _partnerBox.get(_partnerKey);
    if (value == null) {
      return null;
    }
    try {
      return MoneyPartner.fromJson(_asJsonMap(value));
    } catch (error) {
      debugPrint('Skipping unreadable cached money partner: $error');
      return null;
    }
  }

  /// The partner's cached shared spending within [range] (inclusive),
  /// newest first; every one when [range] is null, none when not linked.
  List<MoneyEntry> getEntries({DateTimeRange? range}) {
    if (getPartner() == null) {
      return const [];
    }
    final entries = <MoneyEntry>[];
    for (final value in _entriesBox.values) {
      try {
        final entry = MoneyEntry.fromJson(_asJsonMap(value));
        // RLS already only returns these; checked again so a stale or
        // odd row can never show something the partner kept private.
        if (entry.type == EntryType.spending &&
            entry.visibility == EntryVisibility.shared &&
            (range == null || _inRange(entry.date, range))) {
          entries.add(entry);
        }
      } catch (error) {
        debugPrint('Skipping unreadable cached partner entry: $error');
      }
    }
    entries.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
    return entries;
  }

  /// Replaces the cache with Supabase's link and the partner's shared
  /// spending — clears both when the link is gone (unlinked on either
  /// phone).
  Future<void> refresh() async {
    final partner = await _datasource.getPartner();
    if (partner == null) {
      await _clear();
      return;
    }
    final entries = await _datasource.getPartnerEntries(partner.id);
    await _partnerBox.put(_partnerKey, partner.toJson());
    await _entriesBox.clear();
    for (final entry in entries) {
      await _entriesBox.put(entry.id, entry.toJson());
    }
  }

  /// A fresh code for the other phone to scan.
  Future<MoneyLinkInvite> createInvite() => _datasource.createInvite();

  /// Links with the account that showed [code], then loads the partner.
  /// Throws [MoneyLinkException].
  Future<void> acceptInvite(String code) async {
    await _datasource.acceptInvite(code);
    await refresh();
  }

  /// Unlinks both accounts and forgets the partner's spending.
  Future<void> unlink() async {
    await _datasource.unlink();
    await _clear();
  }

  Future<void> _clear() async {
    await _partnerBox.clear();
    await _entriesBox.clear();
  }

  static bool _inRange(DateTime date, DateTimeRange range) =>
      !date.isBefore(range.start) && !date.isAfter(range.end);

  // Hive hands back loosely typed maps; a JSON round trip restores
  // Map<String, dynamic>.
  static Map<String, dynamic> _asJsonMap(Object value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
}

/// The Hive box caching the linked partner.
final moneyPartnerBoxProvider = FutureProvider<Box<dynamic>>(
  (ref) => Hive.openBox<dynamic>(MoneyPartnerRepository.partnerBoxName),
);

/// The Hive box caching the partner's shared spending, keyed by entry id.
final partnerMoneyEntriesBoxProvider = FutureProvider<Box<dynamic>>(
  (ref) => Hive.openBox<dynamic>(MoneyPartnerRepository.entriesBoxName),
);

/// The app-wide [MoneyPartnerRepository]. Hand-written — see SPEC.md Stack
/// decisions, Code generation.
final moneyPartnerRepositoryProvider = FutureProvider<MoneyPartnerRepository>(
  (ref) async => MoneyPartnerRepository(
    partnerBox: await ref.watch(moneyPartnerBoxProvider.future),
    entriesBox: await ref.watch(partnerMoneyEntriesBoxProvider.future),
  ),
);
