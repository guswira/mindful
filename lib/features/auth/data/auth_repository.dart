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

  bool _initialized = false;

  /// Must complete before any other method on this repository is called.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: googleServerClientId,
    );
    _initialized = true;
  }

  /// Restores a previous session with no user interaction, returning null
  /// if none is available.
  Future<User?> attemptSilentSignIn() async {
    return _supabase.auth.currentSession?.user;
  }

  /// Starts an interactive Google sign-in, then exchanges the Google ID
  /// token for a Supabase session.
  Future<User> signIn() async {
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
    await GoogleSignIn.instance.signOut();
    await _supabase.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();
