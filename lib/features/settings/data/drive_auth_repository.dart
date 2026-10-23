import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/authorized_http_client.dart';
import '../../auth/data/auth_repository.dart';
import '../../../shared/services/drive_service.dart';

part 'drive_auth_repository.g.dart';

/// Requests and revokes the Drive OAuth scope, separately from Google
/// sign-in — per SPEC.md, Drive access is opt-in from Settings, never
/// requested at login time.
class DriveAuthRepository {
  const DriveAuthRepository({this.ensureGoogleSignIn});

  /// Initializes google_sign_in (AuthRepository.initialize) if it isn't
  /// yet — on web nothing else does, so Google's sign-in script is only
  /// downloaded once Drive is actually used.
  final Future<void> Function()? ensureGoogleSignIn;

  static const List<String> _scopes = [DriveService.scope];

  /// Whether the signed-in Google account has already granted Drive
  /// access.
  ///
  /// On web the grant is a short-lived token held in the page, so after a
  /// reload this reads false until the user connects again.
  Future<bool> isConnected() async {
    final client = await _authorizationClient();
    if (client == null) {
      return false;
    }
    final authorization = await client.authorizationForScopes(_scopes);
    return authorization != null;
  }

  /// Requests the Drive scope, prompting the user if needed.
  Future<void> connect() async {
    final client = await _requireAuthorizationClient();
    await client.authorizeScopes(_scopes);
  }

  /// Revokes this app's Drive access on Google's side.
  Future<void> disconnect() async {
    final client = await _authorizationClient();
    final authorization = await client?.authorizationForScopes(_scopes);
    if (authorization == null) {
      return;
    }
    await http.post(
      Uri.parse('https://oauth2.googleapis.com/revoke'),
      body: {'token': authorization.accessToken},
    );
  }

  /// An [http.Client] authorized for Drive, for an already-connected
  /// account. Throws if Drive isn't connected.
  Future<http.Client> authorizedClient() async {
    final client = await _requireAuthorizationClient();
    final authorization = await client.authorizationForScopes(_scopes);
    if (authorization == null) {
      throw StateError('Drive is not connected.');
    }
    return AuthorizedHttpClient(authorization.accessToken);
  }

  /// On web there's no Google account session — sign-in goes through
  /// Supabase's redirect — so scopes are requested from the app-level
  /// client, which asks Google for the account in its own popup.
  Future<GoogleSignInAuthorizationClient?> _authorizationClient() async {
    await ensureGoogleSignIn?.call();
    if (kIsWeb) {
      return GoogleSignIn.instance.authorizationClient;
    }
    return (await _currentAccount())?.authorizationClient;
  }

  Future<GoogleSignInAuthorizationClient> _requireAuthorizationClient() async {
    final client = await _authorizationClient();
    if (client == null) {
      throw StateError('Not signed in with Google.');
    }
    return client;
  }

  /// `attemptLightweightAuthentication` returns a nullable `Future` on some
  /// platforms (a bare `null` meaning "check `authenticationEvents`
  /// instead"). This app only needs a best-effort synchronous check, so a
  /// bare `null` is treated the same as "no account".
  Future<GoogleSignInAccount?> _currentAccount() async {
    final result = GoogleSignIn.instance.attemptLightweightAuthentication();
    return result == null ? null : await result;
  }
}

@Riverpod(keepAlive: true)
DriveAuthRepository driveAuthRepository(Ref ref) => DriveAuthRepository(
  ensureGoogleSignIn: ref.read(authRepositoryProvider).initialize,
);
