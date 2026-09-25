import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/food_scan.dart';

/// Reads, writes and deletes food scans in Supabase. See SPEC.md AI Lab
/// Feature Supabase schema.
class SupabaseFoodScanDatasource {
  SupabaseFoodScanDatasource({SupabaseClient? client})
    : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Inserts a new food scan row.
  Future<void> saveScan(FoodScan scan) async {
    await _client.from(SupabaseConstants.foodScansTable).insert(scan.toJson());
  }

  /// The signed-in user's last [limit] scans (RLS-scoped), newest first.
  Future<List<FoodScan>> getRecentScans({int limit = 10}) async {
    final rows = await _client
        .from(SupabaseConstants.foodScansTable)
        .select()
        .order('scanned_at', ascending: false)
        .limit(limit);
    return [for (final row in rows) FoodScan.fromJson(row)];
  }

  /// Deletes the food scan with [id].
  Future<void> deleteScan(String id) async {
    await _client.from(SupabaseConstants.foodScansTable).delete().eq('id', id);
  }
}
