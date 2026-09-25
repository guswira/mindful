import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/authorized_http_client.dart';
import '../../../shared/services/drive_service.dart';

part 'drive_auth_repository.g.dart';

/// Requests and revokes the Drive OAuth scope, separately from Google
/// sign-in — per SPEC.md, Drive access is opt-in from Settings, never
/// requested at login time.
class DriveAuthRepository {
  const DriveAuthRepository();

  static const List<String> _scopes = [DriveService.scope];

  /// Whether the signed-in Google account has already granted Drive
  /// access.
  Future<bool> isConnected() async {
    final account = await _currentAccount();
    if (account == null) {
      return false;
    }
    final authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);
    return authorization != null;
  }

  /// Requests the Drive scope, prompting the user if needed.
  Future<void> connect() async {
    final account = await _requireAccount();
    await account.authorizationClient.authorizeScopes(_scopes);
  }

  /// Revokes this app's Drive access on Google's side.
  Future<void> disconnect() async {
    final account = await _currentAccount();
    final authorization = await account?.authorizationClient
        .authorizationForScopes(_scopes);
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
    final account = await _requireAccount();
    final authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);
    if (authorization == null) {
      throw StateError('Drive is not connected.');
    }
    return AuthorizedHttpClient(authorization.accessToken);
  }

  /// `attemptLightweightAuthentication` returns a nullable `Future` on some
  /// platforms (a bare `null` meaning "check `authenticationEvents`
  /// instead"). This app only needs a best-effort synchronous check, so a
  /// bare `null` is treated the same as "no account".
  Future<GoogleSignInAccount?> _currentAccount() async {
    final result = GoogleSignIn.instance.attemptLightweightAuthentication();
    return result == null ? null : await result;
  }

  Future<GoogleSignInAccount> _requireAccount() async {
    final account = await _currentAccount();
    if (account == null) {
      throw StateError('Not signed in with Google.');
    }
    return account;
  }
}

@Riverpod(keepAlive: true)
DriveAuthRepository driveAuthRepository(Ref ref) => const DriveAuthRepository();
