import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../domain/breathing_session.dart';

/// Reads and writes breathing sessions in Supabase. See SPEC.md Exercise
/// Supabase schema.
class SupabaseBreathingDatasource {
  SupabaseBreathingDatasource({SupabaseClient? client})
    : _clientOverride = client;

  final SupabaseClient? _clientOverride;

  // Resolved lazily so merely constructing this datasource doesn't require
  // Supabase.initialize() to have already run (e.g. in widget tests).
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Every session belonging to the signed-in user (RLS-scoped), newest
  /// first.
  Future<List<BreathingSession>> getSessions() async {
    final rows = await _client
        .from(SupabaseConstants.breathingSessionsTable)
        .select()
        .order('started_at', ascending: false);
    return [for (final row in rows) BreathingSession.fromJson(row)];
  }

  /// Upserts rather than inserts, so retrying a write whose response was
  /// lost (but which did land) doesn't fail forever on a duplicate id.
  Future<void> saveSession(BreathingSession session) async {
    await _client
        .from(SupabaseConstants.breathingSessionsTable)
        .upsert(session.toJson());
  }
}
