import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/google_auth_config.dart';

part 'auth_repository.g.dart';

/// Google sign-in for authentication, exchanged for a Supabase session.
///
/// Only the Supabase session is kept alive after sign-in — the Google
/// session itself is not persisted. Supabase's client handles session
/// persistence and token refresh transparently.
class AuthRepository {
  AuthRepository({SupabaseClient? supabaseClient})
    : _supabaseOverride = supabaseClient;

  final SupabaseClient? _supabaseOverride;

  // Resolved lazily, not in the constructor, so merely constructing this
  // repository doesn't require Supabase.initialize() to have already run
  // (e.g. in widget tests that never reach a signed-in state).
  SupabaseClient get _supabase => _supabaseOverride ?? Supabase.instance.client;

  Future<void>? _initializing;

  /// Must complete before any other method on this repository is called.
  /// Safe to call concurrently and repeatedly — every caller shares one
  /// initialization (google_sign_in allows only one); a failed one is
  /// retried on the next call.
  Future<void> initialize() => _initializing ??= _initializeGoogleSignIn()
      .catchError((Object error, StackTrace stackTrace) {
        _initializing = null;
        Error.throwWithStackTrace(error, stackTrace);
      });

  Future<void> _initializeGoogleSignIn() async {
    // google_sign_in's web plugin takes the Web client ID as `clientId`
    // and doesn't support `serverClientId`. On web it's only used for
    // Drive's scope request in Settings — sign-in itself goes through
    // Supabase (see [signIn]).
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? googleServerClientId : null,
      serverClientId: kIsWeb ? null : googleServerClientId,
    );
  }

  /// Restores a previous session with no user interaction, returning null
  /// if none is available.
  Future<User?> attemptSilentSignIn() async {
    return _supabase.auth.currentSession?.user;
  }

  /// Starts an interactive Google sign-in, then exchanges the Google ID
  /// token for a Supabase session.
  ///
  /// Returns null on web, where it only starts Supabase's Google redirect:
  /// google_sign_in v7 has no `authenticate()` in a browser, so the page
  /// leaves for Google and comes back with the session in its URL, which
  /// `Supabase.initialize` picks up before [attemptSilentSignIn] runs.
  Future<User?> signIn() async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
      return null;
    }
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in did not return an ID token.');
    }
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Supabase did not return a user for this session.');
    }
    return user;
  }

  /// Signs out of both Google and Supabase. Drive's connection (if any) is
  /// left untouched — it's managed separately in Settings.
  Future<void> signOut() async {
    await initialize();
    await GoogleSignIn.instance.signOut();
    await _supabase.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();
