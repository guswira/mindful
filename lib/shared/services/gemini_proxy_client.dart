import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Name of the Supabase Edge Function that holds the Gemini API key
/// (supabase/functions/gemini-proxy).
const String geminiProxyFunctionName = 'gemini-proxy';

/// Sends the Gemini SDK's requests through the `gemini-proxy` Edge
/// Function instead of straight to Google, so the API key never ships in
/// the app — on web `.env` is a public asset anyone can download.
///
/// Keeps the SDK's path (`/v1beta/models/<model>:generateContent`) and
/// body unchanged, swaps its placeholder API key for the signed-in user's
/// Supabase JWT, and passes Google's response through as-is — so the SDK
/// still parses Gemini's errors and [GeminiService]'s classification keeps
/// working.
class GeminiProxyClient extends http.BaseClient {
  GeminiProxyClient({SupabaseClient? supabaseClient, http.Client? inner})
    : _supabaseOverride = supabaseClient,
      _inner = inner ?? http.Client();

  final SupabaseClient? _supabaseOverride;
  final http.Client _inner;

  SupabaseClient get _supabase => _supabaseOverride ?? Supabase.instance.client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final base = Uri.parse(dotenv.env['SUPABASE_URL'] ?? '');
    final proxied = http.Request(
      request.method,
      base.replace(
        path: '/functions/v1/$geminiProxyFunctionName${request.url.path}',
        query: request.url.hasQuery ? request.url.query : null,
      ),
    );
    final token = _supabase.auth.currentSession?.accessToken;
    proxied.headers
      ..addAll(request.headers)
      ..remove('x-goog-api-key')
      ..['apikey'] = dotenv.env['SUPABASE_ANON_KEY'] ?? ''
      ..['Authorization'] = 'Bearer ${token ?? ''}';
    if (request is http.Request) {
      proxied.bodyBytes = request.bodyBytes;
    }
    return _inner.send(proxied);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
