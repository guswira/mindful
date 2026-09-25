import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OAuth configuration for Google Sign-In.
///
/// `google_sign_in` v7's Android implementation is backed by Credential
/// Manager, which — unlike the old native Android flow — can't infer the
/// app's OAuth client from its package name and signing certificate alone.
/// It requires the **Web application** OAuth 2.0 client ID (not the Android
/// one) to be passed explicitly as `serverClientId`; without it,
/// `GoogleSignIn.instance.authenticate()` fails with
/// "serverClientId must be provided on Android".
///
/// To get one, in Google Cloud Console (the project backing this app's
/// Drive access):
/// 1. Enable the Google Drive API, if not already enabled.
/// 2. Under APIs & Services > Credentials, create an OAuth 2.0 Client ID of
///    type "Android", using this app's applicationId (see
///    `android/app/build.gradle.kts`) and its signing certificate's SHA-1
///    fingerprint — for local debug runs:
///    `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
/// 3. Create a second OAuth 2.0 Client ID of type "Web application". Its
///    Client ID is what belongs below — it isn't used to sign in directly,
///    it's the audience Google validates the Android client against.
/// 4. For iOS, create a third OAuth 2.0 Client ID of type "iOS" with this
///    app's bundle ID (`PRODUCT_BUNDLE_IDENTIFIER` in
///    `ios/Runner.xcodeproj`). It isn't passed from Dart — the iOS SDK
///    reads it from `GIDClientID` in `ios/Runner/Info.plist`, which also
///    needs its reversed form (`com.googleusercontent.apps.<id>`) under
///    `CFBundleURLTypes` so Google can redirect back into the app after
///    sign-in. On iOS the ID token's audience is this iOS client ID even
///    though [googleServerClientId] is passed, so Supabase's Google provider
///    (Auth > Providers > Google > Client IDs, comma-separated) must list it
///    alongside the Web client ID — otherwise `signInWithIdToken` fails
///    with "Unacceptable audience in id_token".
///
/// Read from `GOOGLE_SERVER_CLIENT_ID` in `.env` so the ID isn't committed.
/// Throws a [StateError] if it's missing, since sign-in can't work without it.
String get googleServerClientId {
  final id = dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID');
  if (id == null || id.isEmpty) {
    throw StateError('GOOGLE_SERVER_CLIENT_ID must be set in .env');
  }
  return id;
}
