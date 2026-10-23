import 'package:flutter/foundation.dart';

/// Whether this is a phone build (iOS/Android) rather than desktop or web.
///
/// home_widget, quick_actions and image_picker's camera source only ship
/// phone implementations — calling them elsewhere throws
/// MissingPluginException. Reads [defaultTargetPlatform] so tests can
/// override it.
bool get isPhonePlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

/// Whether this is the native iOS app — false in a browser, even Safari on
/// an iPhone, where [defaultTargetPlatform] still reports iOS.
///
/// Use this (not `dart:io` Platform, which throws on web) before anything
/// that needs the iOS runner: App Group widgets, method channels, the
/// audio session.
bool get isNativeIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Whether this is the native Android app — false in a browser on Android.
bool get isNativeAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Whether the app runs in a browser, where reminders, home screen widgets
/// and shortcuts don't exist (flutter_local_notifications has no web
/// implementation and quietly does nothing there).
bool get isWebPlatform => kIsWeb;
