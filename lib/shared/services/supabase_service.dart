import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes and exposes the app's single Supabase client.
class SupabaseService {
  const SupabaseService();

  /// Reads `SUPABASE_URL`/`SUPABASE_ANON_KEY` from the loaded `.env` file
  /// and initializes Supabase. Must complete before [client] is read.
  Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || anonKey == null) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env',
      );
    }
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  /// The app's single Supabase client, valid after [initialize] completes.
  SupabaseClient get client => Supabase.instance.client;
}
